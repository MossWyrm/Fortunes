extends Button

var input_made = false
var force_disable: bool = false
@onready var overlay = $TextureRect/DisableOverlay

func _ready():
	pressed.connect(_button_pressed)
	Events.card_draw_animation_finish.connect(_release_button_lock)
	Events.pause_drawing.connect(disable_button)

func _button_pressed():
	if !input_made:
		input_made = true
		Events.emit_draw_card()
	else:
		Events.emit_clear_card()

func _release_button_lock():
	input_made = false

func disable_button(pause: bool) -> void:
	overlay.visible = pause || force_disable
	disabled = pause || force_disable
	
func force_disable_button(disable: bool) -> void:
	force_disable = disable
	disable_button(disable)