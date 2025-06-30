extends Control

@onready var skip_button: Button = $MarginContainer/HBoxContainer/SkipButton
@onready var dont_skip_button: Button = $MarginContainer/HBoxContainer/ContinueButton

func _ready() -> void:
	Events.choose_skip.connect(start_skip_choice)
	skip_button.pressed.connect(skip)
	dont_skip_button.pressed.connect(dont_skip)

func start_skip_choice() -> void:
	Stats.pause_drawing = true
	show()
	
func skip() -> void:
	Events.emit_skip_choice(true)
	hide()
	Stats.pause_drawing = false
 
func dont_skip() -> void:
	Events.emit_skip_choice(false)
	hide()
	Stats.pause_drawing = false
	