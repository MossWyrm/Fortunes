extends Node


@export var cup_upgrades: Array[BaseUpgrade]
@export var wand_upgrades: Array[BaseUpgrade]
@export var pent_upgrades: Array[BaseUpgrade]
@export var sword_upgrades: Array[BaseUpgrade]
@export var major_upgrades: Array[BaseUpgrade]
@export var general_upgrades: Array[BaseUpgrade]
var upgrades_dict = {}


func _ready():
	upgrades_dict = {
	0: cup_upgrades, 
	1: wand_upgrades, 
	2: pent_upgrades, 
	3: sword_upgrades, 
	4: major_upgrades,
	5: general_upgrades
	}

func upgrades_list(suit: int):
	return upgrades_dict[suit]