extends Control

@onready var cup: TextureButton = $MarginContainer/HBoxContainer/Cups
@onready var wands: TextureButton = $MarginContainer/HBoxContainer/Wands
@onready var pentacles: TextureButton = $MarginContainer/HBoxContainer/Pentacles
@onready var swords: TextureButton = $MarginContainer/HBoxContainer/Swords
@onready var majors: TextureButton = $MarginContainer/HBoxContainer/Majors

func _ready() -> void:
	Events.choose_suit.connect(start_suit_choice)
	
func start_suit_choice(include_majors: bool = false) -> void:
	Stats.pause_drawing = true
	majors.visible = include_majors
	show()
	
func emit_chosen_suit(suit_num: int) -> void:
	var suit: DataStructures.SuitType = DataStructures.SuitType[DataStructures.SuitType.keys()[suit_num]]
	Events.emit_chosen_suit(suit)
	hide()
	Stats.pause_drawing = false