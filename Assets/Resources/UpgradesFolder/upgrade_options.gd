extends Resource
class_name UpgradeOptions

@export var cup_upgrades: Array[BaseUpgrade]
@export var wand_upgrades: Array[BaseUpgrade]
@export var pent_upgrades: Array[BaseUpgrade]
@export var sword_upgrades: Array[BaseUpgrade]
@export var major_upgrades: Array[BaseUpgrade]
@export var general_upgrades: Array[BaseUpgrade]

var upgrades_dict: Dictionary = {}

func upgrades_list(suit: ID.UpgradeType = ID.UpgradeType.GENERAL) -> Array[BaseUpgrade]:
	if upgrades_dict.size() == 0:
		upgrades_dict = {
		0: cup_upgrades,
		1: wand_upgrades,
		2: pent_upgrades,
		3: sword_upgrades,
		4: major_upgrades,
		5: general_upgrades
		}
	return upgrades_dict[suit]