extends RefCounted
class_name CardCalculator

# === Dependencies ===
var game_state: GameState
# Note: EventBus is now an autoload, no longer need to store reference


# === Suit Calculators ===
var cup_calculator: CupCalculator
var wand_calculator: WandCalculator
var pentacle_calculator: PentacleCalculator
var sword_calculator: SwordCalculator
var major_calculator: MajorCalculator

# === Node References ===
var display_state_manager: DisplayStateManager

# === Setup & Lifecycle ===
func set_game_state(state: GameState):
	game_state = state
	_connect_signals()

func _connect_signals():
	print("CardCalculator: Connecting to EventBus autoload...")
	# Direct connection to autoload EventBus - no timing issues!
	EventBus.game_initialized.connect(_on_game_initialized)
	EventBus.card_drawn.connect(_on_card_drawn)
	EventBus.shuffle_completed.connect(_on_shuffle_completed)
	print("CardCalculator: Signal connections completed")


func _exit_tree():
	_disconnect_signals()

func _disconnect_signals():
	if EventBus:
		EventBus.game_initialized.disconnect(_on_game_initialized)
		EventBus.card_drawn.disconnect(_on_card_drawn)
		EventBus.shuffle_completed.disconnect(_on_shuffle_completed)

func _on_game_initialized():
	print("CardCalculator: Game initialized")
	_setup_calculators()
	_update_suit_displays()

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

func set_display_state_manager(manager: DisplayStateManager):
	display_state_manager = manager

# === Event Handlers ===
func _on_shuffle_completed(safely: bool):
	cup_calculator.shuffle(safely)
	wand_calculator.shuffle(safely)
	pentacle_calculator.shuffle(safely)
	sword_calculator.shuffle(safely)
	major_calculator.shuffle(safely)
	_update_suit_displays()

func _on_card_drawn(card: Card, flipped: bool):
	var result = await calculate_card(card, flipped)
	EventBus.emit_card_calculated(card, result)
	_update_suit_displays()

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

# === Calculation Pipeline ===
func calculate_card(card: Card, flipped: bool) -> CardCalculationResult:
	var result = CardCalculationResult.new()
	await pre_calculate(card, flipped)
	result.base_value = calculate_base_value(card, flipped)
	result.modified_value = await calculate_main_value(card, result.base_value, flipped)
	result.final_value = calculate_post_value(result.modified_value)
	result.clairvoyance_change = result.final_value
	if result.clairvoyance_change != 0:
		EventBus.emit_currency_updated(result.clairvoyance_change, DataStructures.CurrencyType.CLAIRVOYANCE)
	return result

func simulate_card(card: Card, flipped: bool) -> CardCalculationResult:
	var state_backup = create_state_backup()
	var result = await calculate_card(card, flipped)
	restore_state_backup(state_backup)
	return result

# === Pre-calc Phase ===
func pre_calculate(card: Card, flipped: bool) -> void:
	if major_calculator.devil_active():
		if major_calculator.devil_forced():
			EventBus.emit_skip_chosen(true)
			major_calculator.devil_use()
			EventBus.emit_request_buff_update(DataStructures.SuitType.MAJOR, {})
			return
		EventBus.emit_skip_choice_requested()
		if await EventBus.skip_chosen:
			major_calculator.devil_use()
			EventBus.emit_request_buff_update(DataStructures.SuitType.MAJOR, {})
			return
	major_calculator.wheel_update(card.suit)
	if pentacle_calculator.check_queen_pent(flipped):
		flipped = !flipped
	sword_calculator.update_swords(flipped)

# === Base Calculation Phase ===
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
			print("card doesn't have suit")
			return 0
	output += major_calculator.emperor_value()
	if major_calculator.star_active():
		output = major_calculator.star_value(output)
	major_calculator.empress_update(output)
	major_calculator.chariot_update(output)
	return output

# === Main Calculation Phase ===
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

# === Post-calc Phase ===
func calculate_post_value(main_value: int) -> int:
	var result = main_value
	if wand_calculator.wand_knight_check():
		result = roundi(float(result) * wand_calculator.wand_knight_multi())
	if result < 0:
		result = pentacle_calculator.use_pentacles(result)
	result += major_calculator.empress_value()
	if major_calculator.wheel_active():
		result = major_calculator.wheel_value(result)
	if major_calculator.temperance_active():
		result = major_calculator.temperance_value(result)
	if major_calculator.tower_active():
		result = major_calculator.tower_value(result)
	if major_calculator.judgement_active():
		result = major_calculator.judgement_value(result)
	return result

# === State Backup/Restore ===
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