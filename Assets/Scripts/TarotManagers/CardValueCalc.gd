extends Node
class_name CVC

@export var cups_node: cups_calc
@export var wands_node: wands_calc
@export var pentacles_node: pentacles_calc
@export var swords_node: swords_calc
@export var majors_node: majors_calc


func _ready() -> void:
	GM.cv_manager = self
	Events.selected_card.connect(_calculate_card_value)
	
	# Connect to new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state:
		game_manager.game_state.event_bus.card_drawn.connect(_on_new_card_drawn)

func _on_new_card_drawn(card: RefCounted):
	# Handle new architecture card drawn events
	# For now, skip processing as the legacy system handles this
	pass

# Handles the full card value calculation process when a card is selected
func _calculate_card_value(card: Card, flipped = false) -> void:
	# Run any pre-calculation logic (may modify flipped, trigger events, etc)
	await pre_calc(card, flipped)

	# Calculate the base value of the card
	var base_value: int = base_calc(card, flipped)
	# Run the main calculation for the card, possibly async for majors
	var main_value: int = await main_calc(card, base_value, flipped)
	# Apply any post-calculation modifications
	var post_value: int = post_calc(main_value)

	if post_value != 0:
		# Use new architecture if available
		var game_manager = get_node("/root/GameManager")
		if game_manager and game_manager.game_state:
			game_manager.game_state.event_bus.emit_currency_updated(0, post_value)  # 0 for clairvoyance
		else:
			# Legacy fallback
			Events.emit_update_currency(post_value)
	
	Events.emit_update_suit_displays()

# New method: Run card calculations without applying results (for simulation)
func simulate_card_calculation(card: Card, flipped = false) -> Dictionary:
	# Create comprehensive state backup
	var state_backup = create_state_backup()
	
	# Run the full calculation logic (it will update state, but we'll restore it)
	await pre_calc(card, flipped)
	var base_value: int = base_calc(card, flipped)
	var main_value: int = await main_calc(card, base_value, flipped)
	var post_value: int = post_calc(main_value)
	
	# Restore all state
	restore_state_backup(state_backup)
	
	# Return simulation results
	return {
		"base_value": base_value,
		"main_value": main_value,
		"post_value": post_value,
		"final_value": post_value,
		"clairvoyance_change": post_value
	}

# Create a comprehensive backup of all relevant state
func create_state_backup() -> Dictionary:
	var backup = {
		"empress_collection": majors_node.empress_collection.duplicate(),
		"chariot_tracker": majors_node.chariot_tracker.duplicate(),
		"major_states": majors_node._major_states.duplicate(true),  # Deep copy
		"swords_state": swords_node.get_display().duplicate(true),
		"cups_state": cups_node.get_display().duplicate(true),
		"wands_state": wands_node.get_display().duplicate(true),
		"pentacles_state": pentacles_node.get_display().duplicate(true)
	}
	
	# Use new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
		backup["clairvoyance"] = game_manager.game_state.game_stats.clairvoyance
	else:
		# Legacy fallback
		backup["clairvoyance"] = Stats.clairvoyance
	
	return backup

# Restore state from backup
func restore_state_backup(backup: Dictionary) -> void:
	# Use new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
		game_manager.game_state.game_stats.clairvoyance = backup["clairvoyance"]
	else:
		# Legacy fallback
		Stats.clairvoyance = backup["clairvoyance"]
	
	majors_node.empress_collection = backup["empress_collection"]
	majors_node.chariot_tracker = backup["chariot_tracker"]
	majors_node._major_states = backup["major_states"]
	
	# Restore suit-specific states
	# Note: This assumes the suit trackers have restore methods or we can set their state directly
	# You may need to implement restore methods in each suit tracker
	restore_suit_state(swords_node, backup["swords_state"])
	restore_suit_state(cups_node, backup["cups_state"])
	restore_suit_state(wands_node, backup["wands_state"])
	restore_suit_state(pentacles_node, backup["pentacles_state"])

# Helper to restore suit state
func restore_suit_state(suit_node, state: Dictionary) -> void:
	if suit_node.has_method("restore_state"):
		suit_node.restore_state(state)
	else:
		print("Warning: ", suit_node.get_class(), " does not have restore_state method")
	
func get_display(suit: DataStructures.SuitType) -> Dictionary:
	match suit:
		DataStructures.SuitType.CUPS:
			return cups_node.get_display()
		DataStructures.SuitType.WANDS:
			return wands_node.get_display()
		DataStructures.SuitType.PENTACLES:
			return pentacles_node.get_display()
		DataStructures.SuitType.SWORDS:
			return swords_node.get_display()
		DataStructures.SuitType.MAJOR:
			return majors_node.get_display()
		_:
			return {}
			
func wand_knight_value() -> float:
	return wands_node.wand_knight_multi() if wands_node.wand_knight_check() else 1.0
	
func _pentacles_queen_check(flipped) -> bool:
	return pentacles_node.check_queen_pent(flipped)
	
func pre_calc(card: Card, flipped: bool) -> void:
	if majors_node.devil_active():
		if majors_node.devil_forced():
			Events.emit_skip_choice(true)
			majors_node.devil_use()
			Events.emit_update_suit_displays()
			return
		Events.emit_choose_skip()
		if await Events.skip_choice:
			majors_node.devil_use()
			Events.emit_update_suit_displays()
			return
	if majors_node.wheel_requires_check():
		majors_node.wheel_trigger(card.card_suit)
	if _pentacles_queen_check(flipped):
		flipped = !flipped
	swords_node.update_swords(flipped)

func base_calc(card: Card, flipped: bool) -> int:
	var base_value: int = 0
	match card.card_suit:
		DataStructures.SuitType.CUPS:
			base_value = cups_node.get_base_value(card.card_default_value)
		DataStructures.SuitType.WANDS:
			base_value = wands_node.get_base_value(card.card_default_value)
		DataStructures.SuitType.PENTACLES:
			base_value = pentacles_node.get_base_value(card.card_default_value)
		DataStructures.SuitType.SWORDS:
			base_value = swords_node.get_base_value(card.card_default_value)
		DataStructures.SuitType.MAJOR:
			base_value = majors_node.get_base_value(card.card_default_value)
		_:
			print("card doesn't have suit")
			return 0
	base_value += majors_node.get_emperor()
	if majors_node.star_active(flipped):
		base_value = majors_node.star_trigger(base_value)
	majors_node.update_empress(base_value)
	majors_node.update_chariot(base_value)
	return base_value
	
func main_calc(card: Card, base_value: int, flipped: bool) -> int:
	var card_val: int = 0
	match card.card_suit:
		DataStructures.SuitType.CUPS:
			card_val = cups_node.draw(card, base_value, flipped)
		DataStructures.SuitType.WANDS:
			card_val = wands_node.draw(card, base_value, flipped)
		DataStructures.SuitType.PENTACLES:
			card_val = pentacles_node.draw(card, base_value, flipped)
		DataStructures.SuitType.SWORDS:
			card_val = swords_node.draw(card, base_value, flipped)
		DataStructures.SuitType.MAJOR:
			card_val = await majors_node.draw(card, base_value, flipped)
	return card_val
	
func post_calc(value: int) -> int:
	var card_val: int = roundi(float(value) * wand_knight_value())

	if card_val < 0:
		card_val = pentacles_node.use_pentacles(card_val)
	card_val += majors_node.get_empress()
	if majors_node.wheel_active():
		card_val = majors_node.wheel_mod(card_val)
	if majors_node.temperance_active():
		card_val = majors_node.temperance_trigger(card_val)
	if majors_node.tower_active():
		card_val = majors_node.tower_trigger(card_val)

	if majors_node.judgement_active():
		card_val = majors_node.judgement_mod(card_val)

	return card_val