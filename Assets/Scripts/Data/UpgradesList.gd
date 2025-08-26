class_name UpgradesList
extends RefCounted

## Centralized upgrade definitions using builder pattern for cleaner code
## Each upgrade type has its own section with helper methods to reduce repetition

#region Upgrade Creation Helpers
## Creates a basic upgrade with common defaults
func _upgrade(name: String, desc: String, cost: float, stat: String, value: float, id: int = 0) -> Dictionary:
	return {
		"NAME": name,
		"DESCRIPTION": desc,
		"START_COST": cost,
		"GROWTH": DataStructures.GrowthType.EXPONENTIAL,
		"GROWTH_MOD": 0,
		"STAT": stat,
		"STAT_PATH": stat,  # For UpgradeManager compatibility
		"OPERATION": UpgradeData.OperationType.ADD,
		"OPERATION_VALUE": value,
		"ID": id
	}

## Creates upgrade with custom growth pattern
func _upgrade_growth(name: String, desc: String, cost: float, stat: String, value: float, growth: DataStructures.GrowthType, growth_mod: float, id: int = 0) -> Dictionary:
	var upgrade = _upgrade(name, desc, cost, stat, value, id)
	upgrade["GROWTH"] = growth
	upgrade["GROWTH_MOD"] = growth_mod
	return upgrade

## Creates upgrade with operation type override
func _upgrade_op(name: String, desc: String, cost: float, stat: String, value: float, operation: UpgradeData.OperationType, id: int = 0) -> Dictionary:
	var upgrade = _upgrade(name, desc, cost, stat, value, id)
	upgrade["OPERATION"] = operation
	return upgrade

## Creates one-time purchase upgrade
func _upgrade_once(name: String, desc: String, cost: float, stat: String, value, operation: UpgradeData.OperationType = UpgradeData.OperationType.ADD, currency: DataStructures.CurrencyType = DataStructures.CurrencyType.CLAIRVOYANCE, id: int = 0) -> Dictionary:
	var upgrade = _upgrade(name, desc, cost, stat, value)
	upgrade["OPERATION"] = operation
	upgrade["GROWTH"] = DataStructures.GrowthType.LINEAR
	upgrade["MAX_UPGRADES"] = 1
	upgrade["CURRENCY_TYPE"] = currency
	upgrade["ID"] = id
	return upgrade

## Creates upgrade with full control over all parameters
func _upgrade_custom(name: String, desc: String, cost: float, stat: String, value, operation: UpgradeData.OperationType, growth: DataStructures.GrowthType, growth_mod: float, id: int = 0) -> Dictionary:
	var upgrade = _upgrade(name, desc, cost, stat, value, id)
	upgrade["OPERATION"] = operation
	upgrade["GROWTH"] = growth
	upgrade["GROWTH_MOD"] = growth_mod
	return upgrade

# Helper for creating pack upgrades with special properties
func _upgrade_pack(name: String, description: String, start_cost: float, stat: String, operation_value, operation: UpgradeData.OperationType, growth: DataStructures.GrowthType = DataStructures.GrowthType.LINEAR, growth_mod: float = 0, max_upgrades: int = 1) -> Dictionary:
	return {
		"NAME": name,
		"DESCRIPTION": description,
		"START_COST": start_cost,
		"GROWTH": growth,
		"GROWTH_MOD": growth_mod,
		"STAT": stat,
		"STAT_PATH": stat,
		"OPERATION": operation,
		"OPERATION_VALUE": operation_value,
		"MAX_UPGRADES": max_upgrades,
		"CURRENCY_TYPE": DataStructures.CurrencyType.PACK
		}
#endregion

#region General Upgrades
var general_upgrade_values: Dictionary = {
	inversion_chance_modifier = _upgrade_growth(
		"Lucky",
		"Increase the chance for a positive orientation by 0.5%",
		100.0,
		"inversion_chance_modifier",
		0.5,
		DataStructures.GrowthType.SUPERLINEAR,
		4
	),
	max_deck_size = _upgrade_growth(
		"Variety",
		"Increase the maximum size of your deck by 1.",
		250.0,
		"max_deck_size",
		1.0,
		DataStructures.GrowthType.SUPERLINEAR,
		3.5
	),
	min_deck_size = _upgrade_custom(
		"Precision",
		"Reduce the minimum cards required in your deck 1.",
		25.0,
		"min_deck_size",
		1.0,
		UpgradeData.OperationType.SUBTRACT,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2,
		0
	)
}
#endregion

#region Cup Upgrades

var cup_upgrade_values: Dictionary = {
	cup_basic_value = _upgrade(
		"Basic Value",
		"Increase the value of numbered cup cards by 1.",
		10.0,
		"cup_stats.basic_value",
		1.0,
		110
	),
	cup_basic_quant = _upgrade_growth(
		"Basic Quantity",
		"Increase the amount of each numbered cup card you can add to your deck by 1.",
		50.0,
		"cup_stats.basic_max_quantity",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		1.5,
		110
	),
	cup_face_quant = _upgrade(
		"Faces Quantity",
		"Increase the amount of each face cup card you can add to your deck by 1.",
		150.0,
		"cup_stats.face_max_quantity",
		1.0,
		114
	),
	cup_vessel_quant = _upgrade_growth(
		"Add Vessel",
		"Add another vessel to the Cups suit system, allowing for more clearvoiyance to be stored.",
		1000.0,
		"cup_stats.vessel_quantity",
		1.0,
		DataStructures.GrowthType.EXPONENTIAL,
		2.0,
		101
	),
	cup_vessel_size = _upgrade_growth(
		"Max Vessel Size",
		"Increase the amount each vessel can hold by 10.",
		50.0,
		"cup_stats.vessel_size",
		10.0,
		DataStructures.GrowthType.SUPERLINEAR,
		3,
		101
	),
	cup_page_mod = _upgrade_growth(
		"Page Upgrade",
		"Increase / Decrease the Max Vessel Size multiplier Page provides.",
		10000.0,
		"cup_stats.page_modifier",
		0.05,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2.5,
		111
	),
	cup_knight_mod = _upgrade_growth(
		"Knight Upgrade",
		"Increase / Decrease the Cup Cards modified by the Knight.",
		1000.0,
		"cup_stats.knight_modifier",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		0.8,
		112
	),
	cup_queen_mod = _upgrade_growth(
		"Queen Upgrade",
		"Increase / Decrease the temporary cups provided by the Queen",
		1000.0,
		"cup_stats.queen_modifier",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		0.7,
		113
	)
}
#endregion

#region Wand Upgrades

var wand_upgrade_values: Dictionary = {
	wand_basic_value = _upgrade(
		"Basic Upgrade",
		"Increase the value of numbered wand cards by 1.",
		10.0,
		"wand_stats.basic_value",
		1.0,
		210
	),
	wand_basic_quant = _upgrade_growth(
		"Basic Quantity",
		"Increase the amount of each numbered wand card you can add to your deck by 1.",
		50.0,
		"wand_stats.basic_max_quantity",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		1.5,
		210
	),
	wand_face_quant = _upgrade(
		"Faces Quantity",
		"Increase the amount of each face wand card you can add to your deck by 1.",
		150.0,
		"wand_stats.face_max_quantity",
		1.0,
		214
	),
	wand_page_mod = _upgrade_growth(
		"Page Upgrade",
		"Increase the power of the Page by 1",
		1500.0,
		"wand_stats.page_modifier",
		1.0,
		DataStructures.GrowthType.SUPERLINEAR,
		7.5,
		211
	),
	wand_knight_mod = _upgrade_growth(
		"Knight Upgrade",
		"Increase the power of the Knight by 1.",
		1500.0,
		"wand_stats.knight_modifier",
		1.0,
		DataStructures.GrowthType.SUBEXPONENTIAL,
		3.0,
		212
	),
	wand_queen_mod = _upgrade(
		"Queen Upgrade",
		"Increase the power of the Queen by 1.",
		250.0,
		"wand_stats.queen_modifier",
		1.0,
		213
	),
	wand_king_mod = _upgrade(
		"King Upgrade",
		"Increase the power of the King by 1.",
		1250.0,
		"wand_stats.king_modifier",
		1.0,
		214
	)
}
#endregion

#region Pentacle Upgrades

var pent_upgrade_values: Dictionary = {
	pent_basic_value = _upgrade(
		"Basic Upgrade",
		"Increase the value of numbered pentacle cards by 1.",
		10.0,
		"pent_stats.basic_value",
		1.0,
		310
	),
	pent_basic_quant = _upgrade_growth(
		"Basic Quantity",
		"Increase the amount of each numbered pentacle card you can add to your deck by 1.",
		50.0,
		"pent_stats.basic_max_quantity",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		1.5,
		310
	),
	pent_face_quant = _upgrade(
		"Faces Quantity",
		"Increase the amount of each face pentacle card you can add to your deck by 1.",
		150.0,
		"pent_stats.face_max_quantity",
		1.0,
		314
	),
	pent_page_mod = _upgrade_growth(
		"Page Upgrade",
		"Increase the power of the page by 0.05",
		1500.0,
		"pent_stats.page_modifier",
		0.05,
		DataStructures.GrowthType.SUPERLINEAR,
		7.5,
		311
	),
	pent_knight_mod = _upgrade_growth(
		"Knight Upgrade",
		"Increase the power of the Knight by 1.",
		1500.0,
		"pent_stats.knight_modifier",
		1.0,
		DataStructures.GrowthType.SUBEXPONENTIAL,
		3.0,
		312
	),
	pent_queen_mod = _upgrade(
		"Queen Upgrade",
		"Increase the power of the Queen by 1.",
		250.0,
		"pent_stats.queen_modifier",
		1.0,
		313
	),
	pent_king_mod = _upgrade(
		"King Upgrade",
		"Increase the amount of charges the king provides by 1.",
		1250.0,
		"pent_stats.king_modifier",
		1.0,
		314
	)
}
#endregion

#region Sword Upgrades
var sword_upgrade_values: Dictionary = {
	sword_basic_value = _upgrade(
		"Basic Upgrade",
		"Increase the value of numbered sword cards by 1.",
		10.0,
		"sword_stats.basic_value",
		1.0,
		410
	),
	sword_basic_quant = _upgrade_growth(
		"Basic Quantity",
		"Increase the amount of each numbered sword card you can add to your deck by 1.",
		50.0,
		"sword_stats.basic_max_quantity",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		1.5,
		410
	),
	sword_face_quant = _upgrade(
		"Faces Quantity",
		"Increase the amount of each face sword card you can add to your deck by 1.",
		150.0,
		"sword_stats.face_max_quantity",
		1.0,
		414
	),
	sword_knight_super = _upgrade_once(
		"Knight Super Upgrade",
		"Once purchased, allows majors to be included in the pool.",
		1500.0,
		"sword_stats.knight_super",
		true,
		UpgradeData.OperationType.ADD,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		414
	),
	sword_knight_mod = _upgrade_growth(
		"Knight Upgrade",
		"Increase the minimum value of the Knight's add/remove effect by 1.",
		1500.0,
		"sword_stats.knight_modifier",
		1.0,
		DataStructures.GrowthType.SUBEXPONENTIAL,
		3.0,
		412
	),
	sword_queen_mod = _upgrade(
		"Queen Upgrade",
		"Increase the power of the Queen by 1.",
		250.0,
		"sword_stats.queen_modifier",
		1.0,
		413
	),
	sword_king_mod = _upgrade(
		"King Upgrade",
		"Increase the cards the King works on by 1.",
		1250.0,
		"sword_stats.king_modifier",
		1.0,
		414
	)
}
#endregion

#region Major Upgrades
var major_upgrade_values: Dictionary = {
	major_quant = _upgrade_growth(
		"Many Majors",
		"Increase the amount of Major Arcana you can have in your deck by 1.",
		100000.0,
		"major_stats.quantity",
		1.0,
		DataStructures.GrowthType.SUPERLINEAR,
		5.0
	),
	major_magician = _upgrade_growth(
		"Mighty Magician",
		"Increase the amount of cards The Magician affects by 1.",
		10000.0,
		"major_stats.magician",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		6.0,
		502
	),
	major_empress = _upgrade_growth(
		"Extended Empress",
		"Increase the backlog of cards The Empress uses by 1.",
		3250.0,
		"major_stats.empress",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		6.0,
		504
	),
	major_emperor = _upgrade(
		"Exuberant Emperor",
		"The Emperor increases the value of cards by 1 more.",
		4000.0,
		"major_stats.emperor",
		1.0,
		505
	),
	major_lovers = _upgrade_growth(
		"Liberated Lovers",
		"Increase the cards The Lovers targets by 1.",
		5000.0,
		"major_stats.lovers",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2.0,
		507
	),
	major_wheel_charges = _upgrade_growth(
		"Widespread Wheel",
		"Increase the cards a successful Wheel of Fortune affects by 1.",
		5500.0,
		"major_stats.wheel_charges",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		6.0,
		511
	),
	major_wheel_mult = _upgrade_growth(
		"Wondrous Wheel",
		"Increase the multiplier of a successful Wheel of Fortune by 0.5.",
		6000.0,
		"major_stats.wheel_multiplier",
		0.5,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		8.0,
		511
	),
	major_temperance = _upgrade_growth(
		"Titanous Temperance",
		"Increase the target line of Temperance by 50.",
		7000.0,
		"major_stats.temperance",
		50.0,
		DataStructures.GrowthType.SUPERLINEAR,
		3.0,
		515
	),
	major_star = _upgrade_growth(
		"Sparkling Star",
		"Increase the value of The Star by 1.",
		8000.0,
		"major_stats.star",
		1.0,
		DataStructures.GrowthType.SUPERLINEAR,
		5.0,
		518
	),
	major_moon = _upgrade_growth(
		"Majestic Moon",
		"Increase the multiplier of The Moon by 1.",
		10000.0,
		"major_stats.moon",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		4.0,
		519
	),
	major_sun_star = _upgrade_growth(
		"Sun Supernova",
		"The Sun adds 2 more Stars to your deck on draw.",
		15000.0,
		"major_stats.sun_star",
		2.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		6.0,
		520
	),
	major_sun_moon = _upgrade_growth(
		"Symbiotic Sun",
		"The Sun adds 1 more Moon to your deck on draw.",
		25000.0,
		"major_stats.sun_moon",
		1.0,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		5.0,
		520
	)
}
#endregion

#region Pack Upgrades
var pack_upgrade_values: Dictionary = {
	pack_auto_draw = _upgrade_pack(
		"Auto Draw",
		"Allows you to draw cards automatically.",
		1.0,
		"pack_auto_draw",
		true,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,
		0,
		1
	),
	pack_auto_draw_speed = _upgrade_pack(
		"Auto Draw Speed",
		"Improves the speed of Auto Draw by 10%%.",
		1.0,
		"pack_auto_draw_speed",
		0.9,
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SUPERLINEAR,
		2,
		1
	),
	pack_card_value = _upgrade_pack(
		"Auto Draw Speed",
		"Improves the speed of Auto Draw by 10%%.",
		10.0,
		"pack_card_value",
		2,
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		0.95,
		1
	)
}
#endregion

#region Upgrade Creation
# returns a dictionary with format <UpgradeData.UpgradeType, <upgrade ID, >
# Create all upgrades directly for UpgradeManager compatibility
func create_all_upgrades() -> Dictionary:
	var all_upgrades: Dictionary = {}

	_create_upgrades_from_category(all_upgrades, general_upgrade_values, UpgradeData.UpgradeType.GENERAL)
	_create_upgrades_from_category(all_upgrades, cup_upgrade_values, UpgradeData.UpgradeType.CUPS)
	_create_upgrades_from_category(all_upgrades, wand_upgrade_values, UpgradeData.UpgradeType.WANDS)
	_create_upgrades_from_category(all_upgrades, pent_upgrade_values, UpgradeData.UpgradeType.PENTACLES)
	_create_upgrades_from_category(all_upgrades, sword_upgrade_values, UpgradeData.UpgradeType.SWORDS)
	_create_upgrades_from_category(all_upgrades, major_upgrade_values, UpgradeData.UpgradeType.MAJOR)
	_create_upgrades_from_category(all_upgrades, pack_upgrade_values, UpgradeData.UpgradeType.PACK)

	return all_upgrades

# Create upgrades from a specific category
func _create_upgrades_from_category(upgrades_dict: Dictionary, category_data: Dictionary, upgrade_type: UpgradeData.UpgradeType):
	for upgrade_id in category_data.keys():
		var data: Dictionary = category_data[upgrade_id]
		var upgrade_data = UpgradeData.new(
			upgrade_id,
			data["NAME"],
			data["DESCRIPTION"],
			data["START_COST"],
			data.get("MAX_UPGRADES", -1),
			data["STAT_PATH"],
			data["OPERATION_VALUE"],
			data.get("OPERATION", UpgradeData.OperationType.ADD),
			data["GROWTH"],
			data.get("GROWTH_MOD", 0),
			upgrade_type,
			data.get("ID", 0)
		)
		upgrades_dict[upgrade_id] = upgrade_data
#endregion