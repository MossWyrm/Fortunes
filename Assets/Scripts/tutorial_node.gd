extends Control

@onready var next_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Next
@onready var next_overlay: ColorRect = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Next/MarginContainer/TextureRect/Overlay
@onready var prev_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Prev
@onready var prev_overlay: ColorRect = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Prev/MarginContainer/TextureRect/Overlay
@onready var close_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Close

@export var tutorial_pages: Array[Node] = []

var current_index: int = 0

func _ready() -> void:
	close_button.pressed.connect(hide)
	prev_button.pressed.connect(previous)
	next_button.pressed.connect(next)
	

func previous() -> void:
	if current_index > 0:
		tutorial_pages[current_index].hide()
		current_index -= 1
		tutorial_pages[current_index].show()
		next_overlay.hide()
		next_button.disabled = false
	if current_index == 0:
		prev_overlay.show()
		prev_button.disabled = true
	
func next() -> void:
	if current_index < tutorial_pages.size() -1:
		tutorial_pages[current_index].hide()
		current_index += 1
		tutorial_pages[current_index].show()
		prev_overlay.hide()
		prev_button.disabled = false
	if current_index == tutorial_pages.size()-1:
		next_overlay.show()
		next_button.disabled = true