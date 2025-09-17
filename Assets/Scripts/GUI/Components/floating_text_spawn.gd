extends Control
class_name FloatingTextSpawn

## Floating text spawn manager
## Spawns floating text instances with positive or negative colors based on value.

@export var colPos: Color
@export var colNeg: Color

const floating_text_scene: PackedScene = preload("res://Assets/Scenes/FloatingText.tscn")

func _ready() -> void:
	EventBus.floating_text_requested.connect(display_text)

func display_text(value: float) -> void:
	var floating_text = floating_text_scene.instantiate()
	var color: Color = colPos if value > 0 else colNeg
	floating_text.update_text(value, color)
	floating_text.position.y = get_child_count() * (floating_text.size.y / 2)
	add_child(floating_text)
