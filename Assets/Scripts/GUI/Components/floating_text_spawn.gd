extends Control
class_name FloatingTextSpawn

@export var colPos: Color
@export var colNeg: Color

const floating_text_scene: PackedScene = preload("res://Assets/Scenes/FloatingText.tscn")

func _ready() -> void:
	SignalManager.safe_connect(GameManager.game_state.event_bus.floating_text_requested, display_text, "FloatingTextSpawn floating_text_requested")

func display_text(value: float) -> void:
	var floating_text = floating_text_scene.instantiate()
	var color: Color = colPos if value > 0 else colNeg
	floating_text.update_text(value, color)
	floating_text.position.y = get_child_count() * (floating_text.size.y / 2)
	add_child(floating_text)
