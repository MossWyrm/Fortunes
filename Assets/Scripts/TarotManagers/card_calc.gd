extends Node
class_name card_calc

func draw(card: Card, flipped = false) -> int:
	match card.card_default_value:
		11:
			return _page(flipped)
		12:
			return _knight(flipped)
		13:
			return _queen(flipped)
		14:
			return _king(flipped)
		_:
			return _basic(card.card_default_value, flipped)
			
func _basic(_value: int, _flipped = false) -> int:
	print("Basics not implemented")
	return 0
	
func _page(_flipped = false) -> int:
	print("Page not implemented")
	return 0
	
func _knight(_flipped = false) -> int:
	print("Knight not implemented")
	return 0

func _queen(_flipped = false) -> int:
	print("Queen not implemented")
	return 0
 
func _king(_flipped = false) -> int:
	print("King not implemented")
	return 0