extends RefCounted
class_name CardCalculator

var game_state: GameState

var cup_calculator: CupCalculator
var wand_calculator: WandCalculator
var pentacle_calculator: PentacleCalculator
var sword_calculator: SwordCalculator
var major_calculator: MajorCalculator

var display_state_manager: BuffDisplayManager

#region Initialization
func set_game_state(state: GameState):
	game_state = state
	_connect_signals()

func _connect_signals():
	DebugManager.print_card_drawing("CardCalculator: Connecting to EventBus autoload...")
	# Direct connection to autoload EventBus - no timing issues!
	EventBus.game_initialized.connect(_on_game_initialized)
	EventBus.card_drawn.connect(_on_card_drawn)
	EventBus.animation_step_completed.connect(_on_animation_step_completed)
	EventBus.shuffle_completed.connect(_on_shuffle_completed)
	EventBus.game_reset.connect(_on_game_reset)
	DebugManager.print_card_drawing("CardCalculator: Signal connections completed")

func _on_game_initialized():
	DebugManager.print_card_drawing("CardCalculator: Game initialized")
	_setup_calculators()

func _setup_calculators():
	cup_calculator = CupCalculator.new()
	wand_calculator = WandCalculator.new()
	pentacle_calculator = PentacleCalculator.new()
	sword_calculator = SwordCalculator.new()
	major_calculator = MajorCalculator.new()
	
	cup_calculator.set_game_state(game_state)
	wand_calculator.set_game_state(game_state)
	pentacle_calculator.set_game_state(game_state)
	sword_calculator.set_game_state(game_state)
	major_calculator.set_game_state(game_state)
#endregion
#region Event Handlers
func _on_shuffle_completed(safely: bool):
	cup_calculator.shuffle(safely)
	wand_calculator.shuffle(safely)
	pentacle_calculator.shuffle(safely)
	sword_calculator.shuffle(safely)
	major_calculator.shuffle(safely)
	_update_suit_displays()

func _on_card_drawn(card: Card, flipped: bool):
	var animation_type = _determine_animation_type(card)
	EventBus.emit_animation_requested(animation_type, card, flipped)
	
	# Wait for animation to reach the appropriate pause point
	match animation_type:
		DataStructures.CardAnimationType.GHOST_NEGATIVE:
			await EventBus.animation_step_completed # Wait for transform completion
		DataStructures.CardAnimationType.GHOST_POSITIVE:
			await EventBus.animation_step_completed # Wait for initial draw completion
		_:
			await EventBus.animation_step_completed # Wait for flip completion
	
	var result = await calculate_card(card, flipped)
	EventBus.emit_card_calculated(card, result)
	_update_suit_displays()

func _on_animation_step_completed(_step: String):
	# This handler is just for the await - the logic is in _on_card_drawn
	pass

func _determine_animation_type(card: Card) -> DataStructures.CardAnimationType:
	if major_calculator.is_high_priestess_active() && card.suit != DataStructures.SuitType.MAJOR:
		if major_calculator.is_high_priestess_forced():
			return DataStructures.CardAnimationType.GHOST_NEGATIVE
		else:
			return DataStructures.CardAnimationType.GHOST_POSITIVE
	elif card.suit == DataStructures.SuitType.MAJOR:
		return DataStructures.CardAnimationType.MAJOR_CARD
	else:
		return DataStructures.CardAnimationType.BASIC_CARD

func _update_suit_displays():
	# --- Emit request_buff_update for all suits after real card draw ---
	var display_states = {
		DataStructures.SuitType.CUPS: cup_calculator.get_display_state(),
		DataStructures.SuitType.WANDS: wand_calculator.get_display_state(),
		DataStructures.SuitType.PENTACLES: pentacle_calculator.get_display_state(),
		DataStructures.SuitType.SWORDS: sword_calculator.get_display_state(),
		DataStructures.SuitType.MAJOR: major_calculator.get_display_state(),
	}
	# Emit request_buff_update for all suits
	for suit in display_states.keys():
		EventBus.emit_request_buff_update(suit, display_states[suit])
#endregion
#region Calculation Phases
# Main entry point for calculating a card's value
func calculate_card(card: Card, flipped: bool) -> CardCalculationResult:
	var result = CardCalculationResult.new()
	await pre_calculate(card, flipped)
	result.base_value = calculate_base_value(card, flipped)
	result.modified_value = await calculate_main_value(card, result.base_value, flipped)
	result.final_value = calculate_post_value(card, result.modified_value)
	result.clairvoyance_change = result.final_value
	if result.clairvoyance_change != 0:
		EventBus.emit_currency_updated(result.clairvoyance_change, DataStructures.CurrencyType.CLAIRVOYANCE)
	return result

func simulate_card(card: Card, flipped: bool) -> CardCalculationResult:
	var state_backup = create_state_backup()
	var result = await calculate_card(card, flipped)
	restore_state_backup(state_backup)
	return result

# pre-calc phase: handle any forced choices or optional choices
func pre_calculate(input_card: Card, flipped: bool) -> void:
	var card = input_card
	if major_calculator.is_high_priestess_active() && input_card.suit != DataStructures.SuitType.MAJOR:
		if major_calculator.is_high_priestess_forced():
			card = major_calculator.get_high_priestess_cards()[randi() % 3]
			EventBus.emit_card_chosen(card)
			_update_suit_displays()
		else:
			EventBus.emit_card_choice_requested(major_calculator.get_high_priestess_cards())
			card = await EventBus.card_chosen
			_update_suit_displays()
	if major_calculator.is_devil_active():
		if major_calculator.is_devil_forced():
			EventBus.emit_skip_chosen(true)
			major_calculator.trigger_devil()
			_update_suit_displays()
			return
		EventBus.emit_skip_choice_requested()
		if await EventBus.skip_chosen:
			major_calculator.trigger_devil()
			_update_suit_displays()
			return
	major_calculator.update_hermit(card)
	major_calculator.update_judgement(card)
	major_calculator.update_strength(0) # Update Strength at start of pre-calc phase, but only if not skipped
	major_calculator.update_wheel(card.suit) # Update Wheel with current suit)
	if pentacle_calculator.check_queen_pent(flipped):
		flipped = !flipped
	sword_calculator.update_swords(flipped)

# base calc phase: calculate base value with no modifiers
func calculate_base_value(card: Card, flipped: bool) -> int:
	var output: int = 0
	match card.suit:
		DataStructures.SuitType.CUPS:
			output = cup_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.WANDS:
			output = wand_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.PENTACLES:
			output = pentacle_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.SWORDS:
			output = sword_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.MAJOR:
			output = major_calculator.calculate_base_value(card, flipped)
		_:
			DebugManager.print_card_drawing("CardCalculator: Unknown suit type in calculate_base_value: %s" % str(card.suit), DebugManager.DebugLevel.ERROR)
			return 0
	# Apply Hanged Man base value inversion first (before other modifiers)
	if major_calculator.is_hanged_man_active():
		output = major_calculator.apply_hanged_man_to_base_value(card, output)
	output += major_calculator.get_emperor_bonus()
	if major_calculator.is_star_active():
		output = major_calculator.apply_star_to_card(output)
	major_calculator.update_empress(output)
	return output

# main calc phase: calculate main value with all modifiers
func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
	match card.suit:
		DataStructures.SuitType.CUPS:
			return cup_calculator.calculate_main_value(card, base_value, flipped)
		DataStructures.SuitType.WANDS:
			return wand_calculator.calculate_main_value(card, base_value, flipped)
		DataStructures.SuitType.PENTACLES:
			return pentacle_calculator.calculate_main_value(card, base_value, flipped)
		DataStructures.SuitType.SWORDS:
			return sword_calculator.calculate_main_value(card, base_value, flipped)
		DataStructures.SuitType.MAJOR:
			return await major_calculator.calculate_main_value(card, base_value, flipped)
		_:
			return base_value

# post-calc phase: apply any final modifiers
func calculate_post_value(card: Card, main_value: int) -> int:
	var result = main_value
	if wand_calculator.wand_knight_check():
		result = roundi(float(result) * wand_calculator.wand_knight_multi())
	if result < 0:
		result = pentacle_calculator.use_pentacles(result)
	if card.suit != DataStructures.SuitType.MAJOR:
		result = apply_majors(result)
	# Update Chariot with final calculated values for chaining
	major_calculator.update_chariot(result)
	major_calculator.update_justice(card, result)
	major_calculator.update_death(result)
	return result

# Apply all active major card effects to a non-major card value
func apply_majors(value: int) -> int:
	var result = value
	if major_calculator.is_empress_active():
		result = major_calculator.get_empress_bonus(result)
	if major_calculator.is_hierophant_active():
		result = major_calculator.apply_hierophant_to_card(result)
	if major_calculator.is_strength_active():
		result = major_calculator.apply_strength_to_card(result)
	if major_calculator.is_hermit_active():
		result = major_calculator.apply_hermit_to_card(result)
	if major_calculator.is_wheel_active():
		result = major_calculator.apply_wheel_to_card(result)
	if major_calculator.is_temperance_active():
		result = major_calculator.apply_temperance_to_card(result)
	if major_calculator.is_tower_active():
		result = major_calculator.apply_tower_to_card(result)
	if major_calculator.is_star_active():
		result = major_calculator.apply_star_to_card(result)
	if major_calculator.is_judgement_active():
		result = major_calculator.apply_judgement_to_card(result)
	return result
#endregion
#region State Backup
func create_state_backup() -> Dictionary:
	return {
		"clairvoyance": game_state.stats.clairvoyance,
		"cup_state": cup_calculator.get_state_backup(),
		"wand_state": wand_calculator.get_state_backup(),
		"pentacle_state": pentacle_calculator.get_state_backup(),
		"sword_state": sword_calculator.get_state_backup(),
		"CardState": major_calculator.get_state_backup()
	}

func restore_state_backup(backup: Dictionary):
	game_state.stats.clairvoyance = backup["clairvoyance"]
	cup_calculator.restore_state_backup(backup["cup_state"])
	wand_calculator.restore_state_backup(backup["wand_state"])
	pentacle_calculator.restore_state_backup(backup["pentacle_state"])
	sword_calculator.restore_state_backup(backup["sword_state"])
	major_calculator.restore_state_backup(backup["CardState"])

func _on_game_reset(game_layer: DataStructures.GameLayer) -> void:
	if game_layer >= DataStructures.GameLayer.DECK:
		_setup_calculators()
		_update_suit_displays()
#endregion