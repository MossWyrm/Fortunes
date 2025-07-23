extends Node
class_name UpgradeOptions

@onready var upgrades_dict: Dictionary = UpgradesList.new().get_initial_list()

func upgrades_list(suit: ID.UpgradeType = ID.UpgradeType.GENERAL) -> Dictionary:
	if upgrades_dict.size() == 0:
		upgrades_dict  = UpgradesList.new().get_initial_list()
	return upgrades_dict[suit]
	
func set_upgrades(dictionary: Dictionary) -> void:
	upgrades_dict = dictionary
	
func get_full_list() -> Dictionary:
	return upgrades_dict
	
func reset(type: ID.PrestigeLayer) -> void:
	var new_list = UpgradesList.new().get_initial_list()
	if type >= ID.PrestigeLayer.DECK:
		upgrades_dict[ID.UpgradeType.GENERAL]  = new_list[ID.UpgradeType.GENERAL]
		upgrades_dict[ID.UpgradeType.CUPS]  = new_list[ID.UpgradeType.CUPS]
		upgrades_dict[ID.UpgradeType.PENTACLES]  = new_list[ID.UpgradeType.PENTACLES]
		upgrades_dict[ID.UpgradeType.SWORDS]  = new_list[ID.UpgradeType.SWORDS]
		upgrades_dict[ID.UpgradeType.WANDS]  = new_list[ID.UpgradeType.WANDS]
		upgrades_dict[ID.UpgradeType.MAJOR]  = new_list[ID.UpgradeType.MAJOR]
	if type >= ID.PrestigeLayer.PACK:
		upgrades_dict[ID.UpgradeType.PACK]  = new_list[ID.UpgradeType.PACK]
