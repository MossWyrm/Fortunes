extends Node
class_name UpgradesController

@onready var upgrade_options: UpgradeOptions = UpgradeOptions.new()
@onready var buttons : Array[Node] = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/UpgradeDisplay/MarginContainer/UpgradeButtons.get_children()
@onready var pack_button : TextureButton = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/Navigation/PackButton
@export var select_buttons: Array[TextureButton] = []

var upgrade_button_path: String = "res://Assets/Scenes/Upgrades/upgrade_button.tscn"
var parent: Node

var last_opened: ID.UpgradeType = ID.UpgradeType.GENERAL

func _ready() -> void:
	GM.upgrade_manager = self
	Events.reset.connect(reset_upgrades)
	get_viewport().size_changed.connect(change_size)
	parent = get_parent()
	change_size();
	set_upgrades()

func change_size() -> void:
	self.position.x = 0

func set_upgrades(type: ID.UpgradeType = ID.UpgradeType.GENERAL, texture_button: TextureButton = null) -> void:
	if buttons.size() < upgrade_options.upgrades_list(type).size():
		print("Not enough upgrade containers!")
		return
	last_opened = type
	var upgrades: Dictionary = upgrade_options.upgrades_list(type)
	for n in upgrades.size():
		buttons[n].set_button(upgrades[upgrades.keys()[n]], type)
		buttons[n].visible = true
	for index in range(upgrades.size(),buttons.size()):
		buttons[index].visible = false
	if texture_button != null:
		for button in select_buttons:
			if button == texture_button:
				button.select()
			else:
				button.deselect()
				
func on_toggle_visible() -> void:
	if self.visible:
		set_upgrades(last_opened)
		if Stats.packs > 0 && !pack_button.is_visible():
			pack_button.show()
		
func save() -> Dictionary:
	var save_file: Dictionary = {}
	var upgrades: Dictionary  = upgrade_options.get_full_list()
	for key in upgrades.keys():
		var suit_collection: Dictionary = {}
		for upgrade in upgrades[key].keys():
			suit_collection[upgrade] = upgrades[key][upgrade].times_purchased
		save_file[key] = suit_collection
	return save_file
	
func load_upgrades(dict: Dictionary) -> void:
	var upgrades: Dictionary = upgrade_options.get_full_list()
	if upgrades == null:
		print("Upgrades list not found")
		return
	for suit in dict.keys():
		for title in dict[suit].keys():
			upgrades[int(suit)][title].times_purchased = dict[suit][title]
		
func reset_upgrades(type: ID.PrestigeLayer) -> void:
	upgrade_options.reset(type)