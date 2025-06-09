extends card_calc
class_name cups_calc

@onready var tracker: cup_tracker = get_child(0)

func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = 0
	if flipped:
		updated_value = -value
	else:
		updated_value = value
	return updated_value

func _basic(value, flipped = false) -> int:
	var val: int = _value_modifier(value+Stats.cup_basic_value, flipped)
	tracker.update(val, flipped)
	return tracker.bonus() + val

func _page(flipped = false) -> int:
	var val: int = _value_modifier(11, flipped)
	tracker.update(val, flipped)
	
	var upright_val = roundi(Stats.cup_max_size * Stats.cup_page_positive) - Stats.cup_max_size
	var flipped_val = Stats.cup_max_size - roundi(Stats.cup_max_size*Stats.cup_page_negative)
	Stats.cup_max_size_modifier = flipped_val if flipped else upright_val

	return tracker.bonus() + val

func _knight(flipped = false) -> int:
	var val: int = _value_modifier(12, flipped)
	tracker.update(val, flipped)
	for cards in Stats.cup_knight_mod:
		var random_num: int = randi() % 14 + 101
		if flipped:
			GM.deck_manager.remove_card(ID.Suits.CUPS,0)
		else:
			GM.deck_manager.add_card(random_num)
	return tracker.bonus() + val

func _queen(flipped = false) -> int:
	for cup in Stats.cup_queen_mod:
		if flipped:
			tracker.remove_cup()
		else:
			tracker.add_cup()
	
	var val: int = _value_modifier(13)
	tracker.update(val, flipped)
	
	return tracker.bonus() + val

func _king(flipped = false) -> int:
	var val: int = _value_modifier(14)
	tracker.update(val, flipped)
	if flipped:
		tracker.empty_cups()
	else:
		tracker.fill_cups()
	return tracker.bonus() + val

func get_display() -> Dictionary:
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_display()
