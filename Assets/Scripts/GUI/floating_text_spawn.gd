extends Control

@export var colPos: Color
@export var colNeg: Color

const SceneToLoad = preload("res://Assets/Scenes/FloatingText.tscn")

func _ready():
	Events.floating_text.connect(_display_text)

func _display_text(value):
	var scenetoload = SceneToLoad
	var floating_text = scenetoload.instantiate()
	var color
	if value > 0:
		color = colPos
	else:
		color = colNeg
	floating_text._update_text(value, color)
	floating_text.position.y = self.get_child_count()*(floating_text.size.y/2)
	if(floating_text.get_parent()):
		floating_text.get_parent().remove_child(floating_text)
	add_child(floating_text)
