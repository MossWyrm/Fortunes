extends RefCounted
class_name UpgradeManager

## Manages the upgrade system for the game
## Handles upgrade creation, purchasing, effects application, and persistence

#region Dependencies and Data
# Dependencies
var game_state: GameState


# Upgrade data
var upgrades_list: UpgradesList = UpgradesList.new()
var upgrades: Dictionary = {}
var purchased_upgrades: Dictionary = {}
var formulas: Dictionary = {
	DataStructures.GrowthType.LINEAR : LinearGrowth.new(),
	DataStructures.GrowthType.SUPERLINEAR : SuperlinearGrowth.new(),
	DataStructures.GrowthType.SUBEXPONENTIAL : SuperPolynomialSubExponential.new(),
	DataStructures.GrowthType.EXPONENTIAL : ExponentialGrowth.new(),
	DataStructures.GrowthType.SLOW_EXPONENTIAL : SlowExponentialGrowth.new()		
	}

var game_stats: GameStats
#endregion

#region Initialization
## Sets up the UpgradeManager with game state and initializes all upgrades
func set_game_state(state: GameState):
	if not ValidationUtils.validate_game_state(state):
		push_error("UpgradeManager: Invalid game state provided")
		return
	game_state = state
	game_stats = state.stats

	_connect_events()
	_initialize_upgrades()

## Connects to necessary event bus signals
func _connect_events():
	EventBus.upgrade_purchased.connect(_on_upgrade_purchased)
	EventBus.game_reset.connect(reset)

## Initializes all upgrades using the direct creation method
func _initialize_upgrades():
	# New efficient approach - direct creation from UpgradesList
	_create_upgrades_directly()
	
	# Legacy approach for backwards compatibility
	# _create_upgrades()

## Creates all upgrades directly from UpgradesList and initializes purchase tracking
func _create_upgrades_directly():
	var all_upgrade_data = upgrades_list.create_all_upgrades()
	upgrades = all_upgrade_data
	
	# Initialize purchase tracking
	for upgrade_id in upgrades.keys():
		purchased_upgrades[upgrade_id] = 0
#endregion

#region Upgrade Access and Queries
## Returns the UpgradeData for a specific upgrade ID
func get_upgrade(id: String) -> UpgradeData:
	return upgrades.get(id)

## Returns all upgrades of a specific type
func get_upgrades_for_type(type: UpgradeData.UpgradeType) -> Dictionary:
	var result: Dictionary = {}
	for upgrade in upgrades.values():
		if upgrade.type == type:
			result[upgrade.id] = upgrade
	return result

## Calculates the current cost of an upgrade based on purchase count and growth formula
func get_upgrade_cost(id: String) -> float:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return 0.0
	return formulas[upgrade.formula].apply_formula(get_purchase_count(id), upgrade.base_cost, upgrade.additional_formula_input)

## Checks if a player can afford and is allowed to purchase an upgrade
func can_purchase_upgrade(id: String) -> bool:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return false
	if upgrade.max_purchases > 0 && get_purchase_count(id) >= upgrade.max_purchases:
		return false
	
	var cost: float   = get_upgrade_cost(id)
	var currency: int
	match upgrade.type:
		UpgradeData.UpgradeType.PACK:
			currency = game_state.stats.packs
		_:
			currency = game_state.stats.clairvoyance
	
	return currency >= cost

## Checks if an upgrade has reached its maximum purchase level
func is_max_level(id: String) -> bool:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return false
	return get_purchase_count(id) >= upgrade.max_purchases if upgrade.max_purchases > 0 else false
#endregion

#region Purchase and Effect Application
## Attempts to purchase an upgrade, deducting currency and applying effects
func purchase_upgrade(id: String) -> bool:
	if not can_purchase_upgrade(id):
		return false
	
	var upgrade: UpgradeData = get_upgrade(id)
	var cost: float          = get_upgrade_cost(id)
	
	# Deduct currency (fixed logic)
	match upgrade.type:
		UpgradeData.UpgradeType.PACK:
			EventBus.emit_currency_updated(-int(cost), DataStructures.CurrencyType.PACK)
		_:
			EventBus.emit_currency_updated(-int(cost), DataStructures.CurrencyType.CLAIRVOYANCE)
	
	# Apply effect
	_apply_upgrade_effect(upgrade)
	
	# Increment purchase count
	purchased_upgrades[id] = get_purchase_count(id) + 1
	
	# Emit event
	EventBus.emit_upgrade_purchased(upgrade)
	
	return true

## Applies the effect of an upgrade to the appropriate game stat
func _apply_upgrade_effect(upgrade: UpgradeData):
	var stat_path: String   = upgrade.stat_name
	var effect_value = upgrade.effect_value
	
	# Navigate to the correct stat object
	var stat_object: Object   = _get_stat_object(stat_path)
	var property_name: String = _get_property_name(stat_path)
	
	if stat_object and property_name:
		var current_value = stat_object.get(property_name)
		
		if effect_value is bool:
			stat_object.set(property_name, effect_value)
		else:
			match upgrade.operation:
				UpgradeData.OperationType.ADD:
					stat_object.set(property_name, current_value + effect_value)
				UpgradeData.OperationType.SUBTRACT:
					stat_object.set(property_name, current_value - effect_value)
				UpgradeData.OperationType.MULTIPLY:
					stat_object.set(property_name, current_value * effect_value)
				UpgradeData.OperationType.DIVIDE:
					stat_object.set(property_name, current_value / effect_value)
#endregion

#region Utility Functions
## Gets the current purchase count for an upgrade
func get_purchase_count(id: String) -> int:
	return purchased_upgrades.get(id, 0)

## Gets all purchased upgrades and their counts
func get_all_purchase_counts() -> Dictionary:
	return purchased_upgrades.duplicate()

## Gets purchase counts for a specific upgrade type
func get_purchase_counts_by_type(upgrade_type: UpgradeData.UpgradeType) -> Dictionary:
	var type_upgrades = get_upgrades_for_type(upgrade_type)
	var type_counts: Dictionary = {}
	
	for upgrade_id in type_upgrades.keys():
		var count = get_purchase_count(upgrade_id)
		if count > 0:
			type_counts[upgrade_id] = count
	
	return type_counts

## Checks if any upgrades of a type are affordable
func has_affordable_upgrades(upgrade_type: UpgradeData.UpgradeType) -> bool:
	var type_upgrades = get_upgrades_for_type(upgrade_type)
	
	for upgrade_id in type_upgrades.keys():
		if can_purchase_upgrade(upgrade_id):
			return true
	
	return false

## Gets purchase progress for an upgrade (for UI display)
func get_upgrade_progress(id: String) -> Dictionary:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return {}
	
	var current_purchases = get_purchase_count(id)
	var max_purchases = upgrade.max_purchases
	var current_cost = get_upgrade_cost(id)
	var can_afford = can_purchase_upgrade(id)
	var is_maxed = is_max_level(id)
	
	return {
		"current_purchases": current_purchases,
		"max_purchases": max_purchases,
		"current_cost": current_cost,
		"can_afford": can_afford,
		"is_maxed": is_maxed,
		"progress_percent": float(current_purchases) / float(max_purchases) if max_purchases > 0 else 0.0
	}

## Debug function to print upgrade status for development
func debug_upgrade_status(id: String) -> void:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		print("Debug: Upgrade '%s' not found" % id)
		return
	
	var progress = get_upgrade_progress(id)
	print("Debug: Upgrade '%s' (%s)" % [id, upgrade.name])
	print("  Purchases: %d/%s" % [progress.current_purchases, str(progress.max_purchases) if progress.max_purchases > 0 else "∞"])
	print("  Cost: %s" % Tools.get_shorthand(int(progress.current_cost)))
	print("  Can afford: %s" % str(progress.can_afford))
	print("  Is maxed: %s" % str(progress.is_maxed))

## Debug function to print all upgrade purchase counts
func debug_all_purchases() -> void:
	var all_counts = get_all_purchase_counts()
	print("Debug: All upgrade purchase counts:")
	for upgrade_id in all_counts.keys():
		var count = all_counts[upgrade_id]
		if count > 0:
			print("  %s: %d" % [upgrade_id, count])

## Gets comprehensive upgrade statistics for analytics/debugging
func get_upgrade_statistics() -> Dictionary:
	var stats: Dictionary = {
		"total_upgrades": upgrades.size(),
		"total_purchases": 0,
		"total_spent_clairvoyance": 0.0,
		"total_spent_packs": 0.0,
		"maxed_upgrades": 0,
		"upgrades_by_type": {},
		"most_purchased": {"id": "", "count": 0}
	}
	
	var most_purchased_count = 0
	
	for upgrade_id in upgrades.keys():
		var upgrade: UpgradeData = get_upgrade(upgrade_id)
		var purchase_count = get_purchase_count(upgrade_id)
		
		# Track total purchases
		stats.total_purchases += purchase_count
		
		# Track most purchased
		if purchase_count > most_purchased_count:
			most_purchased_count = purchase_count
			stats.most_purchased.id = upgrade_id
			stats.most_purchased.count = purchase_count
		
		# Track maxed upgrades
		if is_max_level(upgrade_id):
			stats.maxed_upgrades += 1
		
		# Track by type
		var type_key = str(upgrade.type)
		if not stats.upgrades_by_type.has(type_key):
			stats.upgrades_by_type[type_key] = {"count": 0, "purchases": 0}
		
		stats.upgrades_by_type[type_key].count += 1
		stats.upgrades_by_type[type_key].purchases += purchase_count
		
		# Calculate total spent (approximate based on base cost * purchases)
		var total_cost_approx = upgrade.base_cost * purchase_count
		match upgrade.type:
			UpgradeData.UpgradeType.PACK:
				stats.total_spent_packs += total_cost_approx
			_:
				stats.total_spent_clairvoyance += total_cost_approx
	
	return stats
#endregion

#region Stat Path Utilities
## Gets the object that contains the stat to be modified
func _get_stat_object(stat_path: String) -> Object:
	var path_parts: PackedStringArray = stat_path.split(".")
	
	if path_parts.size() == 1:
		# Direct stat
		return game_state.stats
	elif path_parts.size() == 2:
		# Nested stat (e.g., "cup_stats.basic_value")
		var stat_obj_name: String = path_parts[0]
		return game_state.stats.get(stat_obj_name)
	
	return null

## Extracts the property name from a stat path
func _get_property_name(stat_path: String) -> String:
	var path_parts: PackedStringArray = stat_path.split(".")
	
	if path_parts.size() == 1:
		return stat_path
	elif path_parts.size() == 2:
		return path_parts[1]
	
	return ""
#endregion

#region Event Handling
## Handles post-purchase logic when an upgrade is purchased
func _on_upgrade_purchased(_upgrade: UpgradeData):
	# Handle any post-purchase logic
	pass
#endregion

#region Reset and Persistence
## Resets purchased upgrades based on game layer reset type
func reset(reset_type: DataStructures.GameLayer):
	if reset_type >= DataStructures.GameLayer.DECK:
		var deck_upgrades: Array = purchased_upgrades.keys().filter(func(x: String): return get_upgrade(x).type <= UpgradeData.UpgradeType.GENERAL)
		for upgrade_id in deck_upgrades:
			purchased_upgrades[upgrade_id] = 0

	if reset_type >= DataStructures.GameLayer.PACK:
		var pack_upgrades: Array = purchased_upgrades.keys().filter(func(x: String): return get_upgrade(x).type == UpgradeData.UpgradeType.PACK)
		for upgrade_id in pack_upgrades:
			purchased_upgrades[upgrade_id] = 0

	if reset_type >= DataStructures.GameLayer.ALL:
		purchased_upgrades.clear()
		for upgrade_id in upgrades.keys():
			purchased_upgrades[upgrade_id] = 0

## Saves the current state of purchased upgrades
func save() -> Dictionary:
	return purchased_upgrades.duplicate()

## Loads purchased upgrade data from a save file
func load(data: Dictionary):
	purchased_upgrades = data.duplicate()
#endregion