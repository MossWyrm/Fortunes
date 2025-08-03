extends Node
class_name UpgradeOptions

@onready var upgrades_dict: Dictionary = UpgradesList.new().get_initial_list()

func upgrades_list(suit: DataStructures.UpgradeData.UpgradeType = DataStructures.UpgradeData.UpgradeType.GENERAL) -> Dictionary:
	if upgrades_dict.size() == 0:
		upgrades_dict  = UpgradesList.new().get_initial_list()
	return upgrades_dict[suit]
	
func set_upgrades(dictionary: Dictionary) -> void:
	upgrades_dict = dictionary
	
func get_full_list() -> Dictionary:
	return upgrades_dict
	
func reset(type: DataStructures.GameLayer) -> void:
	var new_list = UpgradesList.new().get_initial_list()
	if type >= DataStructures.GameLayer.DECK:
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.GENERAL]  = new_list[DataStructures.UpgradeData.UpgradeType.GENERAL]
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.CUPS]  = new_list[DataStructures.UpgradeData.UpgradeType.CUPS]
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.PENTACLES]  = new_list[DataStructures.UpgradeData.UpgradeType.PENTACLES]
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.SWORDS]  = new_list[DataStructures.UpgradeData.UpgradeType.SWORDS]
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.WANDS]  = new_list[DataStructures.UpgradeData.UpgradeType.WANDS]
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.MAJOR]  = new_list[DataStructures.UpgradeData.UpgradeType.MAJOR]
	if type >= DataStructures.GameLayer.PACK:
		upgrades_dict[DataStructures.UpgradeData.UpgradeType.PACK]  = new_list[DataStructures.UpgradeData.UpgradeType.PACK]
