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
	
func reset() -> void:
	upgrades_dict  = UpgradesList.new().get_initial_list()