extends Node
class_name card_calc

# Base class for card calculation logic for all suits

var card_value: int = 0

# Main entry point for calculating the value of a card draw.
func draw(card: Card, value: int, flipped = false) -> int:
	card_value = value
	match card.card_id_num % 100:
		11:
			return _page(flipped)
		12:
			return _knight(flipped)
		13:
			return _queen(flipped)
		14:
			return _king(flipped)
		_:
			return _basic( flipped)

# Default calculation for basic cards (override in subclasses)		
func _basic(_flipped = false) -> int:
	print("Basics not implemented")
	return 0
	
# Page card calculation (override in subclasses)
func _page(_flipped = false) -> int:
	print("Page not implemented")
	return 0
	
# Knight card calculation (override in subclasses)
func _knight(_flipped = false) -> int:
	print("Knight not implemented")
	return 0

# Queen card calculation (override in subclasses)
func _queen(_flipped = false) -> int:
	print("Queen not implemented")
	return 0
 
# King card calculation (override in subclasses)
func _king(_flipped = false) -> int:
	print("King not implemented")
	return 0

# Returns the base value for a card (override in subclasses)	
func get_base_value(_value: int) -> int:
	print("get base value not implemented")
	return 0
	
# Returns a display dictionary for UI (override in subclasses)
func get_display() -> Dictionary:
	print("get display not implemented")
	return {}