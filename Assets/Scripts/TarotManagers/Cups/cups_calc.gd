extends card_calc
class_name cups_calc

@onready var tracker: cup_tracker = get_child(0)

# Handles value inversion for flipped cards
func _value_modifier(value, flipped = false) -> int:
	return -value if flipped else value
	
# Basic card calculation for Cups
func _basic(flipped = false) -> int:
	var val: int = _value_modifier(card_value, flipped)
	tracker.update(val, flipped)
	return tracker.bonus() + val

# Page card calculation for Cups
func _page(flipped = false) -> int:
	var val: int = _value_modifier(card_value, flipped)
	tracker.update(val, flipped)
	
	tracker.draw_page(flipped)

	return tracker.bonus() + val

# Knight card calculation for Cups
func _knight(flipped = false) -> int:
	var val: int = _value_modifier(card_value, flipped)
	tracker.update(val, flipped)
	for cards in Stats.cup_knight_mod:
		var random_num: int = randi() % 14 + 101
		if flipped:
			GM.deck_manager.remove_card(ID.Suits.CUPS,0)
		else:
			GM.deck_manager.add_card(random_num)
	return tracker.bonus() + val

# Queen card calculation for Cups
func _queen(flipped = false) -> int:
	for cup in Stats.cup_queen_mod:
		if flipped:
			tracker.remove_cup()
		else:
			tracker.add_cup()
	
	var val: int = _value_modifier(card_value)
	tracker.update(val, flipped)
	
	return tracker.bonus() + val

# King card calculation for Cups
func _king(flipped = false) -> int:
	var val: int = _value_modifier(card_value)
	tracker.update(val, flipped)
	if flipped:
		tracker.empty_cups()
	else:
		tracker.fill_cups()
	return tracker.bonus() + val

# Returns display dictionary for Cups
func get_display() -> Dictionary:
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_display()
	
# Returns base value for Cups
func get_base_value(value: int) -> int:
	return value + Stats.cup_basic_value
