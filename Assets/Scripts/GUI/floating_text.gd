extends Node


@export var text_display: Node

func _update_text(value, color : Color):
	text_display.text = str("%.2+f" % value)
	text_display.label_settings.font_color = color
	$AnimationPlayer.play("floating_text_anim")

func _destroy_self():
	self.queue_free()
