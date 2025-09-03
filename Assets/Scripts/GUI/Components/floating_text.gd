extends Node

## Floating text component

@export var text_display: Label

func update_text(value, color : Color) -> void:
	text_display.text = Tools.get_shorthand(value)
	text_display.label_settings.font_color = color
	$AnimationPlayer.play("floating_text_anim")

func _destroy_self() -> void:
	queue_free()
