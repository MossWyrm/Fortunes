extends Node
class_name suit_tracker

func _ready() -> void:
	Events.shuffle.connect(shuffle)
	
func update(_value, _flipped = false) -> void:
	return
	
func shuffle(_safely: bool) -> void:
	print("shuffle not implemented")
	pass
	
func get_display() -> Dictionary:
	print("display not implemented")
	return {}