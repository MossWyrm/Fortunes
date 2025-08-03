extends RefCounted
class_name CardCalculator

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Suit calculators
var cup_calculator: CupCalculator
var wand_calculator: WandCalculator
var pentacle_calculator: PentacleCalculator
var sword_calculator: SwordCalculator
var major_calculator: MajorCalculator

func _init():
	cup_calculator = CupCalculator.new()
	wand_calculator = WandCalculator.new()
	pentacle_calculator = PentacleCalculator.new()
	sword_calculator = SwordCalculator.new()
	major_calculator = MajorCalculator.new()

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()
	_setup_calculators()

func _connect_events():
	event_bus.card_drawn.connect(_on_card_drawn)

func _setup_calculators():
	cup_calculator.set_game_state(game_state)
	wand_calculator.set_game_state(game_state)
	pentacle_calculator.set_game_state(game_state)
	sword_calculator.set_game_state(game_state)
	major_calculator.set_game_state(game_state)

func _on_card_drawn(card: DataStructures.Card, flipped: bool):
	var result = await calculate_card(card, flipped)
	event_bus.emit_card_calculated(card, result)

func calculate_card(card: DataStructures.Card, flipped: bool) -> DataStructures.CardCalculationResult:
	var result = DataStructures.CardCalculationResult.new()
	
	# Pre-calculation phase
	await pre_calculate(card, flipped)
	
	# Base calculation
	result.base_value = calculate_base_value(card, flipped)
	
	# Main calculation
	result.modified_value = await calculate_main_value(card, result.base_value, flipped)
	
	# Post-calculation
	result.final_value = calculate_post_value(result.modified_value)
	result.clairvoyance_change = result.final_value
	
	# Apply currency change
	if result.clairvoyance_change != 0:
		game_state.stats.clairvoyance += result.clairvoyance_change
		event_bus.emit_currency_updated(result.clairvoyance_change, DataStructures.CurrencyType.CLAIRVOYANCE)
	
	return result

func simulate_card(card: DataStructures.Card, flipped: bool) -> DataStructures.CardCalculationResult:
	# Create state backup
	var state_backup = create_state_backup()
	
	# Run full calculation
	var result = await calculate_card(card, flipped)
	
	# Restore state
	restore_state_backup(state_backup)
	
	return result

func pre_calculate(_card: DataStructures.Card, _flipped: bool):
	# Handle any pre-calculation logic (modifications to flipped state, etc)
	pass

func calculate_base_value(card: DataStructures.Card, flipped: bool) -> int:
	match card.suit:
		DataStructures.SuitType.CUPS:
			return cup_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.WANDS:
			return wand_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.PENTACLES:
			return pentacle_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.SWORDS:
			return sword_calculator.calculate_base_value(card, flipped)
		DataStructures.SuitType.MAJOR:
			return major_calculator.calculate_base_value(card, flipped)
		_:
			return 0

func calculate_main_value(card: DataStructures.Card, base_value: int, flipped: bool) -> int:
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

func calculate_post_value(main_value: int) -> int:
	# Apply any global post-calculation modifiers
	return main_value

func create_state_backup() -> Dictionary:
	return {
		"clairvoyance": game_state.stats.clairvoyance,
		"cup_state": cup_calculator.get_state_backup(),
		"wand_state": wand_calculator.get_state_backup(),
		"pentacle_state": pentacle_calculator.get_state_backup(),
		"sword_state": sword_calculator.get_state_backup(),
		"major_state": major_calculator.get_state_backup()
	}

func restore_state_backup(backup: Dictionary):
	game_state.stats.clairvoyance = backup["clairvoyance"]
	cup_calculator.restore_state_backup(backup["cup_state"])
	wand_calculator.restore_state_backup(backup["wand_state"])
	pentacle_calculator.restore_state_backup(backup["pentacle_state"])
	sword_calculator.restore_state_backup(backup["sword_state"])
	major_calculator.restore_state_backup(backup["major_state"])