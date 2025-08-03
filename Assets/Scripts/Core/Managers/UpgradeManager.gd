extends RefCounted
class_name UpgradeManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Upgrade data
var upgrades: Dictionary = {}
var purchased_upgrades: Dictionary = {}
var formulas: Dictionary = {
	DataStructures.GrowthType.LINEAR = LinearGrowth.new(),
	DataStructures.GrowthType.SUPERLINEAR = SuperlinearGrowth.new(),
	DataStructures.GrowthType.SUBEXPONENTIAL = SuperPolynomialSubExponential.new(),
	DataStructures.GrowthType.EXPONENTIAL = ExponentialGrowth.new(),
	DataStructures.GrowthType.SLOW_EXPONENTIAL = SlowExponentialGrowth.new()		
	}

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()
	_initialize_upgrades()

func _connect_events():
	event_bus.upgrade_purchased.connect(_on_upgrade_purchased)

func _initialize_upgrades():
	_create_general_upgrades()
	_create_suit_upgrades()

func _create_general_upgrades():
	# General upgrades
	_add_upgrade("gen_inversion_chance_mod", "Lucky", 
		"Increase the chance for a positive orientation by 0.5%", 
		100.0, 0.5, "inversion_chance_modifier")
	
	_add_upgrade("gen_max_deck_size", "Variety", 
		"Increase the maximum size of your deck by 1.", 
		250.0, 1, "max_deck_size")
	
	_add_upgrade("gen_min_deck_size", "Precision", 
		"Increase the minimum cards required in your deck by 1.", 
		25.0, -1, "min_deck_size")

func _create_suit_upgrades():
	# Cup upgrades
	_add_upgrade("cup_basic_value", "Basic Value", 
		"Increase the value of numbered cup cards by 1.", 
		10.0, 1, "cup_stats.basic_value")
	
	_add_upgrade("cup_basic_quant", "Basic Quantity", 
		"Increase the amount of each numbered cup card you can add to your deck by 1.", 
		50.0, 1, "cup_stats.basic_max_quantity")
	
	_add_upgrade("cup_face_quant", "Faces Quantity", 
		"Increase the amount of each face cup card you can add to your deck by 1.", 
		150.0, 1, "cup_stats.face_max_quantity")
	
	_add_upgrade("cup_vessel_quant", "Add Vessel", 
		"Add another vessel to the Cups suit system, allowing for more clairvoyance to be stored.", 
		1000.0, 1, "cup_stats.vessel_quantity")
	
	_add_upgrade("cup_vessel_size", "Max Vessel Size", 
		"Increase the amount each vessel can hold by 10.", 
		50.0, 10, "cup_stats.vessel_size")
	
	_add_upgrade("cup_page_mod", "Page Upgrade", 
		"Increase / Decrease the Max Vessel Size multiplier Page provides.", 
		10000.0, 0.1, "cup_stats.page_modifier")
	
	_add_upgrade("cup_knight_mod", "Knight Upgrade", 
		"Increase / Decrease the multiplier Knight provides.", 
		5000.0, 1, "cup_stats.knight_modifier")
	
	_add_upgrade("cup_queen_mod", "Queen Upgrade", 
		"Increase / Decrease the multiplier Queen provides.", 
		7500.0, 1, "cup_stats.queen_modifier")
	
	# Wand upgrades
	_add_upgrade("wand_basic_value", "Basic Value", 
		"Increase the value of numbered wand cards by 1.", 
		10.0, 1, "wand_stats.basic_value")
	
	_add_upgrade("wand_basic_quant", "Basic Quantity", 
		"Increase the amount of each numbered wand card you can add to your deck by 1.", 
		50.0, 1, "wand_stats.basic_max_quantity")
	
	_add_upgrade("wand_face_quant", "Faces Quantity", 
		"Increase the amount of each face wand card you can add to your deck by 1.", 
		150.0, 1, "wand_stats.face_max_quantity")
	
	_add_upgrade("wand_page_mod", "Page Upgrade", 
		"Increase / Decrease the modifier Page provides.", 
		1000.0, 1, "wand_stats.page_modifier")
	
	_add_upgrade("wand_knight_mod", "Knight Upgrade", 
		"Increase / Decrease the modifier Knight provides.", 
		2000.0, 1, "wand_stats.knight_modifier")
	
	_add_upgrade("wand_queen_mod", "Queen Upgrade", 
		"Increase / Decrease the modifier Queen provides.", 
		3000.0, 1, "wand_stats.queen_modifier")
	
	_add_upgrade("wand_king_mod", "King Upgrade", 
		"Increase / Decrease the modifier King provides.", 
		5000.0, 1, "wand_stats.king_modifier")
	
	# Pentacle upgrades
	_add_upgrade("pent_basic_value", "Basic Value", 
		"Increase the value of numbered pentacle cards by 1.", 
		10.0, 1, "pentacle_stats.basic_value")
	
	_add_upgrade("pent_basic_quant", "Basic Quantity", 
		"Increase the amount of each numbered pentacle card you can add to your deck by 1.", 
		50.0, 1, "pentacle_stats.basic_max_quantity")
	
	_add_upgrade("pent_face_quant", "Faces Quantity", 
		"Increase the amount of each face pentacle card you can add to your deck by 1.", 
		150.0, 1, "pentacle_stats.face_max_quantity")
	
	_add_upgrade("pent_page_mod", "Page Upgrade", 
		"Increase / Decrease the modifier Page provides.", 
		1000.0, 0.05, "pentacle_stats.page_modifier")
	
	_add_upgrade("pent_knight_uses", "Knight Uses", 
		"Increase the number of uses Knight provides.", 
		2000.0, 1, "pentacle_stats.knight_uses")
	
	_add_upgrade("pent_queen_uses", "Queen Uses", 
		"Increase the number of uses Queen provides.", 
		3000.0, 1, "pentacle_stats.queen_uses")
	
	_add_upgrade("pent_king_uses", "King Uses", 
		"Increase the number of uses King provides.", 
		5000.0, 1, "pentacle_stats.king_uses")
	
	_add_upgrade("pent_king_value", "King Value", 
		"Increase the value King provides.", 
		10000.0, 50, "pentacle_stats.king_value")
	
	# Sword upgrades
	_add_upgrade("sword_basic_value", "Basic Value", 
		"Increase the value of numbered sword cards by 1.", 
		10.0, 1, "sword_stats.basic_value")
	
	_add_upgrade("sword_basic_quant", "Basic Quantity", 
		"Increase the amount of each numbered sword card you can add to your deck by 1.", 
		50.0, 1, "sword_stats.basic_max_quantity")
	
	_add_upgrade("sword_face_quant", "Faces Quantity", 
		"Increase the amount of each face sword card you can add to your deck by 1.", 
		150.0, 1, "sword_stats.face_max_quantity")
	
	_add_upgrade("sword_knight_mod", "Knight Modifier", 
		"Increase / Decrease the modifier Knight provides.", 
		2000.0, 1, "sword_stats.knight_modifier")
	
	_add_upgrade("sword_knight_super", "Knight Super", 
		"Enable super mode for Knight.", 
		10000.0, true, "sword_stats.knight_super")
	
	_add_upgrade("sword_queen_mod", "Queen Modifier", 
		"Increase / Decrease the modifier Queen provides.", 
		3000.0, 1, "sword_stats.queen_modifier")
	
	_add_upgrade("sword_king_mod", "King Modifier", 
		"Increase / Decrease the modifier King provides.", 
		5000.0, 1, "sword_stats.king_modifier")

func _add_upgrade(id: String, name: String, description: String, base_cost: float, effect_value: Variant, stat_path: String):
	var upgrade = DataStructures.UpgradeData.new(id, name, description, base_cost, -1, stat_path, effect_value)
	upgrades[id] = upgrade
	purchased_upgrades[id] = 0

func get_upgrade(id: String) -> DataStructures.UpgradeData:
	return upgrades.get(id)

func get_upgrade_cost(id: String) -> float:
	var upgrade = get_upgrade(id)
	if not upgrade:
		return 0.0
	
	var times_purchased = purchased_upgrades.get(id, 0)
	return _calculate_cost(upgrade)

func _calculate_cost(upgrade: DataStructures.UpgradeData) -> float:
	return formula[upgrade.formula].apply_formula(upgrade.times_purchased, upgrade.base_cost, upgrade.additional_formula_input)

func can_purchase_upgrade(id: String) -> bool:
	var upgrade = get_upgrade(id)
	if not upgrade:
		return false
	
	var cost = get_upgrade_cost(id)
	var currency = game_state.stats.clairvoyance
	
	return currency >= cost

func purchase_upgrade(id: String) -> bool:
	if not can_purchase_upgrade(id):
		return false
	
	var upgrade = get_upgrade(id)
	var cost = get_upgrade_cost(id)
	
	# Deduct currency
	game_state.stats.clairvoyance -= int(cost)
	
	# Apply effect
	_apply_upgrade_effect(upgrade)
	
	# Increment purchase count
	purchased_upgrades[id] = purchased_upgrades.get(id, 0) + 1
	
	# Emit event
	event_bus.emit_upgrade_purchased(upgrade)
	
	return true

func _apply_upgrade_effect(upgrade: DataStructures.UpgradeData):
	var stat_path = upgrade.stat_name
	var effect_value = upgrade.effect_value
	
	# Navigate to the correct stat object
	var stat_object = _get_stat_object(stat_path)
	var property_name = _get_property_name(stat_path)
	
	if stat_object and property_name:
		var current_value = stat_object.get(property_name)
		
		if effect_value is bool:
			stat_object.set(property_name, effect_value)
		else:
			match upgrade.operation:
				DataStructures.UpgradeData.OperationType.ADD:
					stat_object.set(property_name, current_value + effect_value)
				DataStructures.UpgradeData.OperationType.SUBTRACT:
					stat_object.set(property_name, current_value - effect_value)
				DataStructures.UpgradeData.OperationType.MULTIPLY:
					stat_object.set(property_name, current_value * effect_value)
				DataStructures.UpgradeData.OperationType.DIVIDE:
					stat_object.set(property_name, current_value / effect_value)

func _get_stat_object(stat_path: String):
	var path_parts = stat_path.split(".")
	
	if path_parts.size() == 1:
		# Direct stat
		return game_state.stats
	elif path_parts.size() == 2:
		# Nested stat (e.g., "cup_stats.basic_value")
		var stat_name = path_parts[0]
		return game_state.stats.get(stat_name)
	
	return null

func _get_property_name(stat_path: String) -> String:
	var path_parts = stat_path.split(".")
	
	if path_parts.size() == 1:
		return stat_path
	elif path_parts.size() == 2:
		return path_parts[1]
	
	return ""

func _on_upgrade_purchased(upgrade: DataStructures.UpgradeData):
	# Handle any post-purchase logic
	pass

func reset(reset_type: DataStructures.GameLayer):
	if reset_type >= DataStructures.GameLayer.ALL:
		purchased_upgrades.clear()
		for upgrade_id in upgrades.keys():
			purchased_upgrades[upgrade_id] = 0

func save() -> Dictionary:
	return purchased_upgrades.duplicate()

func load(data: Dictionary):
	purchased_upgrades = data.duplicate()
	
	# Apply all purchased upgrades to restore state
	for upgrade_id in purchased_upgrades.keys():
		var times_purchased = purchased_upgrades[upgrade_id]
		var upgrade = get_upgrade(upgrade_id)
		
		if upgrade:
			for i in range(times_purchased):
				_apply_upgrade_effect(upgrade) 