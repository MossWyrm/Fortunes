extends Node
class_name UpgradesController

@export var cvc: CVC
@export var main: Node
@export var upgrade_options: Node
@export var button_container: Node
var upgrade_button_path = "res://Assets/Scenes/Upgrades/upgrade_button.tscn"
var parent: Node

func _ready():
	get_viewport().size_changed.connect(change_size)
	parent = get_parent()
	change_size();
	Events.upgrade_menu_toggle.connect(set_upgrades)
	set_upgrades()

func change_size():
	self.position.x = parent.size.x

func set_upgrades(suit: int = 5): #5 is for general upgrades
	if button_container.get_child_count() < upgrade_options.upgrades_list(suit).size():
		print("Not enough upgrade containers!")
		return
	var count = 0
	for n in upgrade_options.upgrades_list(suit):
		button_container.get_child(count)._set_button(n)
		button_container.get_child(count).visible = true
		count += 1
	for index in range(count,button_container.get_child_count()):
		button_container.get_child(index).visible = false




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
