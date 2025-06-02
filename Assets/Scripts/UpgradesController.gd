extends Node
class_name UpgradesController

@export var upgrade_options: UpgradeOptions
@export var button_container: Node

var upgrade_button_path: String = "res://Assets/Scenes/Upgrades/upgrade_button.tscn"
var parent: Node

func _ready() -> void:
	get_viewport().size_changed.connect(change_size)
	parent = get_parent()
	change_size();
	Events.upgrade_menu_toggle.connect(set_upgrades)
	set_upgrades()

func change_size() -> void:
	self.position.x = parent.size.x

func set_upgrades(type: ID.UpgradeType = ID.UpgradeType.GENERAL) -> void:
	if button_container.get_child_count() < upgrade_options.upgrades_list(type).size():
		print("Not enough upgrade containers!")
		return
		
	var buttons: Array[Node]         = button_container.get_children()
	var upgrades: Array[BaseUpgrade] = upgrade_options.upgrades_list(type)
	for n in upgrades.size()-1:
		buttons[n]._set_button(upgrades[n])
		buttons[n].visible = true
	for index in range(upgrades.size(),buttons.size()):
		buttons[index].visible = false




"""

Suit Upgrades:
	Cups:
		√ increase max cups 
		√ increase cup max size
		- 1-10:
			- +1 value
			- +1 purchase amount
		- Pa:
		- Kn:
		- Qu:
		- Ki:
	Wands:
		- Percentage of wands applied to all cards
		- 
		- 1-10:
			- +1 value
			- +1 purchase amount
		- Pa:
		- Kn:
		- Qu:
		- Ki:
	Pentacles:
		-
		- 1-10:
			- +1 value
			- +1 purchase amount
		- Pa:
		- Kn:
		- Qu:
		- Ki:
	Swords:
		-
		- 1-10:
			- +1 value
			- +1 purchase amount
		- Pa:
		- Kn:
		- Qu:
		- Ki:

Majors' Upgrades:
	-
	-
	
Deck Upgrades:
	√ Increase chance of upright vs inverted
	√ increase maxiumum deck size
	√ lower minimum deck size

Prestige upgrades:
	- Clearvoiyance mult
	- cheaper prices
"""
