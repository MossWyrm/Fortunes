extends card_calc
class_name wands_calc

@onready var tracker: wand_tracker = get_child(0)

func draw(card: Card, flipped = false) -> int:
	if tracker.page_skip():
		return 0
	var total: int = 0
	for use in tracker.page_multiply():
		total += super.draw(card,flipped)
	return total
	
			
func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = 0
	updated_value = -value if flipped else value
	updated_value += tracker.value_mod
	updated_value = roundi(float(updated_value)*tracker.bonus())
	return updated_value

func _basic(value, flipped = false) -> int:
	var val : int = _value_modifier(value, flipped)
	tracker.update(val / 100.0, flipped)

	return val

func _page(flipped = false) -> int:
	var val : int = _value_modifier(11, flipped)
	tracker.page_drawn(flipped)
	return val

func _knight(flipped = false) -> int:
	var val : int = _value_modifier(12, flipped)
	tracker.knight_drawn(flipped)
	return val

func _queen(flipped = false) -> int:
	var val : int = _value_modifier(13, flipped)
	tracker.queen_drawn(flipped)
	return val

func _king(flipped = false) -> int:
	var val : int = _value_modifier(14, flipped)
	tracker.king_drawn(flipped)
	return val
		
func get_display() -> Dictionary:
	return tracker.get_display()

func wand_knight_check() -> bool:
	return tracker.knight_active

func wand_knight_multi() -> float:
	return tracker.knight_trigger() 
