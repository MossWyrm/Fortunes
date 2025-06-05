extends Control
class_name FloatingTextSpawn

@export var colPos: Color
@export var colNeg: Color

const SceneToLoad: PackedScene = preload("res://Assets/Scenes/FloatingText.tscn")

func _ready() -> void:
	Events.floating_text.connect(display_text)

func display_text(value) -> void:
	var floating_text: Node      = SceneToLoad.instantiate()
	var color: Color = colPos if value > 0 else colNeg
	floating_text.update_text(value, color)
	floating_text.position.y = self.get_child_count()*(floating_text.size.y/2)
	add_child(floating_text)
