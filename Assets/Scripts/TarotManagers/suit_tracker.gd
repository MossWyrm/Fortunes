extends Node
class_name suit_tracker

# Base class for suit trackers, handles suit-specific state and events

func _ready() -> void:
	Events.shuffle.connect(shuffle)
	
# Called when a card is played or updated (override in subclasses)
func update(_value, _flipped = false) -> void:
	return

# Called when the deck is shuffled (override in subclasses)
func shuffle(_safely: bool) -> void:
	print("shuffle not implemented")
	pass
	
# Returns a dictionary for displaying suit state (override in subclasses)
func get_display() -> Dictionary:
	print("display not implemented")
	return {}