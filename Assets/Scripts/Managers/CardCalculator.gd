extends RefCounted
class_name CardCalculator

# === Dependencies ===
var game_state: GameState
var event_bus: EventBus


# === Suit Calculators ===
var cup_calculator: CupCalculator
var wand_calculator: WandCalculator
var pentacle_calculator: PentacleCalculator
var sword_calculator: SwordCalculator
var major_calculator: MajorCalculator

# === Node References ===
var display_state_manager: DisplayStateManager

# === Instantiation ===
func _init():
	cup_calculator = CupCalculator.new()
	wand_calculator = WandCalculator.new()
	pentacle_calculator = PentacleCalculator.new()
	sword_calculator = SwordCalculator.new()
	major_calculator = MajorCalculator.new()

# === Setup & Lifecycle ===

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()
	_setup_calculators()

func _connect_events():
	event_bus.card_drawn.connect(_on_card_drawn)
	event_bus.request_shuffle.connect(_on_shuffle_requested)

func _setup_calculators():
	cup_calculator.set_game_state(game_state)
	wand_calculator.set_game_state(game_state)
	pentacle_calculator.set_game_state(game_state)
	sword_calculator.set_game_state(game_state)
	major_calculator.set_game_state(game_state)

func set_display_state_manager(manager: DisplayStateManager):
	display_state_manager = manager
	if manager:
		manager.major_calculator = major_calculator
		manager.cup_calculator = cup_calculator
		manager.wand_calculator = wand_calculator
		manager.sword_calculator = sword_calculator
		manager.pentacle_calculator = pentacle_calculator

# === Event Handlers ===
func _on_shuffle_requested(safely: bool):
	cup_calculator.shuffle(safely)
	wand_calculator.shuffle(safely)
	pentacle_calculator.shuffle(safely)
	sword_calculator.shuffle(safely)
	major_calculator.shuffle(safely)

func _on_card_drawn(card: Card, flipped: bool):
	var result = await calculate_card(card, flipped)
	event_bus.emit_card_calculated(card, result)
	_update_suit_displays()

func _update_suit_displays():
	# --- Emit suit_display_updated for all suits after real card draw ---
	var display_states = {
		DataStructures.SuitType.CUPS: cup_calculator.get_display_state(),
		DataStructures.SuitType.WANDS: wand_calculator.get_display_state(),
		DataStructures.SuitType.PENTACLES: pentacle_calculator.get_display_state(),
		DataStructures.SuitType.SWORDS: sword_calculator.get_display_state(),
		DataStructures.SuitType.MAJOR: major_calculator.get_display_state(),
	}
	display_state_manager.update_display_states(display_states)

# === Calculation Pipeline ===
func calculate_card(card: Card, flipped: bool) -> CardCalculationResult:
	var result = CardCalculationResult.new()
	await pre_calculate(card, flipped)
	result.base_value = calculate_base_value(card, flipped)
	result.modified_value = await calculate_main_value(card, result.base_value, flipped)
	result.final_value = calculate_post_value(result.modified_value)
	result.clairvoyance_change = result.final_value
	if result.clairvoyance_change != 0:
		game_state.stats.clairvoyance += result.clairvoyance_change
		event_bus.emit_currency_updated(result.clairvoyance_change, DataStructures.CurrencyType.CLAIRVOYANCE)
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
			event_bus.emit_skip_choice(true)
			major_calculator.devil_use()
			event_bus.emit_update_suit_displays()
			return
		event_bus.emit_choose_skip()
		if await event_bus.skip_choice:
			major_calculator.devil_use()
			event_bus.emit_update_suit_displays()
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

# === External Requests ===
func get_display(suit: DataStructures.SuitType) -> Dictionary:
	match suit:
		DataStructures.SuitType.CUPS:
			return cup_calculator.get_display()
		DataStructures.SuitType.WANDS:
			return wand_calculator.get_display()
		DataStructures.SuitType.PENTACLES:
			return pentacle_calculator.get_display()
		DataStructures.SuitType.SWORDS:
			return sword_calculator.get_display()
		DataStructures.SuitType.MAJOR:
			return major_calculator.get_display()
		_:
			return {"error": "Unknown Suit"}

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