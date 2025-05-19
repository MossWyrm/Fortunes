extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var newSize : Vector2 = get_viewport_rect().size
	size = newSize

