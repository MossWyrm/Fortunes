extends card_calc
class_name wands_calc

@onready var tracker: wand_tracker = get_child(0)

func draw(card: Card, value: int, flipped = false) -> int:
	if tracker.page_skip():
		return 0
	var total: int = 0
	for use in tracker.page_multiply():
		total += super.draw(card, value ,flipped)
	return total
	
			
func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = 0
	updated_value = -value if flipped else value
	tracker.update(updated_value / 100.0, flipped)
	updated_value = roundi(float(updated_value)*tracker.bonus())
	return updated_value

func _basic(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	return val

func _page(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.page_drawn(flipped)
	return val

func _knight(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.knight_drawn(flipped)
	return val

func _queen(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.queen_drawn(flipped)
	return val

func _king(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.king_drawn(flipped)
	return val
		
func get_display() -> Dictionary:
	return tracker.get_display()

func wand_knight_check() -> bool:
	return tracker.knight_active

func wand_knight_multi() -> float:
	return tracker.knight_trigger() 
	
func get_base_value(value: int) -> int:
	return value + Stats.wand_basic_value + tracker.value_mod
