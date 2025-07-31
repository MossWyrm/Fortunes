extends card_calc
class_name wands_calc

@onready var tracker: wand_tracker = get_child(0)

# Handles drawing a Wands card, including page multiplication logic
func draw(card: Card, value: int, flipped = false) -> int:
	if tracker.page_skip():
		return 0
	var total: int = 0
	for use in tracker.page_multiply():
		total += super.draw(card, value ,flipped)
	return total
	
# Applies value modifications and updates tracker
func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = 0
	updated_value = -value if flipped else value
	tracker.update(updated_value / 100.0, flipped)
	updated_value = roundi(float(updated_value)*tracker.bonus())
	return updated_value

# Basic card calculation for Wands
func _basic(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	return val

# Page card calculation for Wands
func _page(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.page_drawn(flipped)
	return val

# Knight card calculation for Wands
func _knight(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.knight_drawn(flipped)
	return val

# Queen card calculation for Wands
func _queen(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.queen_drawn(flipped)
	return val

# King card calculation for Wands
func _king(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.king_drawn(flipped)
	return val

# Returns display dictionary for Wands
func get_display() -> Dictionary:
	return tracker.get_display()

# Returns true if knight effect is active
func wand_knight_check() -> bool:
	return tracker.knight_active

# Returns knight multiplier value
func wand_knight_multi() -> float:
	return tracker.knight_trigger() 
	
# Returns base value for Wands
func get_base_value(value: int) -> int:
	return value + Stats.wand_basic_value + tracker.value_mod
