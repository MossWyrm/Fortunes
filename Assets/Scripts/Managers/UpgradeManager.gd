extends RefCounted
class_name UpgradeManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

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

func set_game_state(state: GameState):
	if not ValidationUtils.is_valid_game_state(state):
		push_error("UpgradeManager: Invalid game state provided")
		return
	game_state = state
	game_stats = state.stats
	event_bus = state.event_bus
	_connect_events()
	_initialize_upgrades()

func _connect_events():
	SignalManager.safe_connect(event_bus.upgrade_purchased, _on_upgrade_purchased, "UpgradeManager upgrade_purchased")

func _initialize_upgrades():
	_create_upgrades()

func _batch_create_upgrades(upgrade_dict: Dictionary, type: UpgradeData.UpgradeType):
	for upgrade_id in upgrade_dict.keys():
		var upgrade_data = upgrade_dict[upgrade_id]
		_add_upgrade(
			upgrade_id, 
			upgrade_data["NAME"], 
			upgrade_data["DESCRIPTION"], 
			upgrade_data["START_COST"], 
			upgrade_data.get("MAX_UPGRADES", -1), 
			upgrade_data["STAT_PATH"], 
			upgrade_data["OPERATION_VALUE"], 
			upgrade_data.get("OPERATION", UpgradeData.OperationType.ADD), 
			upgrade_data["GROWTH"], 
			upgrade_data.get("GROWTH_MOD", 0),
			type,
			upgrade_data.get("ID", 0)
		)

func _create_upgrades():
	_batch_create_upgrades(upgrades_list.general_upgrade_values, UpgradeData.UpgradeType.GENERAL)
	_batch_create_upgrades(upgrades_list.cup_upgrade_values, UpgradeData.UpgradeType.CUPS)
	_batch_create_upgrades(upgrades_list.wand_upgrade_values, UpgradeData.UpgradeType.WANDS)
	_batch_create_upgrades(upgrades_list.pent_upgrade_values, UpgradeData.UpgradeType.PENTACLES)
	_batch_create_upgrades(upgrades_list.sword_upgrade_values, UpgradeData.UpgradeType.SWORDS)
	_batch_create_upgrades(upgrades_list.major_upgrade_values, UpgradeData.UpgradeType.MAJOR)
	_batch_create_upgrades(upgrades_list.pack_upgrade_values, UpgradeData.UpgradeType.PACK)

func _add_upgrade(id: String, name: String, description: String, base_cost: float, max_upgrades: int, stat_path: String, effect_value: float, operation: UpgradeData.OperationType, formula: DataStructures.GrowthType, additional_formula_input: float, upgrade_type: UpgradeData.UpgradeType, card_id: int = 0):
	var upgrade = UpgradeData.new(id, name, description, base_cost, max_upgrades, stat_path, effect_value, operation, formula, additional_formula_input, upgrade_type, card_id)
	upgrades[id] = upgrade
	purchased_upgrades[id] = 0

func get_upgrade(id: String) -> UpgradeData:
	return upgrades.get(id)

func get_upgrade_cost(id: String) -> float:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return 0.0
	return formulas[upgrade.formula].apply_formula(purchased_upgrades.get(id,0), upgrade.base_cost, upgrade.additional_formula_input)

func can_purchase_upgrade(id: String) -> bool:
	var upgrade: UpgradeData = get_upgrade(id)
	if not upgrade:
		return false
	if upgrade.max_purchases > 0 && purchased_upgrades.get(id,0) >= upgrade.max_purchases:
		return false
	
	var cost: float   = get_upgrade_cost(id)
	var currency: int
	match upgrade.type:
		UpgradeData.UpgradeType.PACK:
			currency = game_state.stats.packs
		_:
			currency = game_state.stats.clairvoyance
	
	return currency >= cost

func purchase_upgrade(id: String) -> bool:
	if not can_purchase_upgrade(id):
		return false
	
	var upgrade: UpgradeData = get_upgrade(id)
	var cost: float          = get_upgrade_cost(id)
	
	# Deduct currency
	match upgrade.type:
		UpgradeData.UpgradeType.PACK:
			game_state.stats.clairvoyance -= int(cost)
		_:
			game_state.stats.packs -= int(cost)
	
	# Apply effect
	_apply_upgrade_effect(upgrade)
	
	# Increment purchase count
	purchased_upgrades[id] = purchased_upgrades.get(id, 0) + 1
	
	# Emit event
	event_bus.emit_upgrade_purchased(upgrade)
	
	return true

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

func _get_property_name(stat_path: String) -> String:
	var path_parts: PackedStringArray = stat_path.split(".")
	
	if path_parts.size() == 1:
		return stat_path
	elif path_parts.size() == 2:
		return path_parts[1]
	
	return ""

func _on_upgrade_purchased(_upgrade: UpgradeData):
	# Handle any post-purchase logic
	pass

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

func save() -> Dictionary:
	return purchased_upgrades.duplicate()

func load(data: Dictionary):
	purchased_upgrades = data.duplicate()