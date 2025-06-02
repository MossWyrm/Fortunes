extends card_calc
class_name cups_calc

@onready var tracker: cup_tracker = get_child(0)
@onready var cvc: CVC = get_parent()

func draw(card, flipped = false):
	if (card.card_default_value >= 0 && card.card_default_value <= 10):
		return _basic_cup(card.card_default_value, flipped)
	elif card.card_default_value == 11:
		return _page_cup(flipped)
	elif card.card_default_value == 12:
		return _knight_cup(flipped)
	elif card.card_default_value == 13:
		return _queen_cup(flipped)
	elif card.card_default_value == 14:
		return _king_cup(flipped)
	else:
		print("Error finding cup card number")

func _value_modifier(value, flipped = false):
	var updated_value: int = 0
	if flipped:
		updated_value = -value
	else:
		updated_value = value
	return updated_value

func _basic_cup(value, flipped = false):
	var val = _value_modifier(value+Stats.cup_basic_value, flipped)
	tracker.update(val, flipped)
	return tracker.bonus() + val

func _page_cup(flipped = false):
	var val = _value_modifier(11, flipped)
	tracker.update(val, flipped)
	if flipped:
		Stats.cup_max_size_modifier = Stats.cup_max_size - roundi(Stats.cup_max_size*Stats.cup_page_negative)
	else:
		Stats.cup_max_size_modifier = roundi(Stats.cup_max_size * Stats.cup_page_positive) - Stats.cup_max_size
	return tracker.bonus() + val

func _knight_cup(flipped = false):
	var val = _value_modifier(12, flipped)
	tracker.update(val, flipped)
	var random_num = randi() % 14 + 101
	if flipped:
		cvc.remove_card(ID.Suits.CUPS,0)
	else:
		cvc.add_card(random_num)
	return tracker.bonus() + val

func _queen_cup(flipped = false):
	if flipped:
		tracker.remove_cup()
	else:
		tracker.add_cup()
	
	var val = _value_modifier(13)
	tracker.update(val, flipped)
	
	return tracker.bonus() + val

func _king_cup(flipped = false):
	var val = _value_modifier(14)
	tracker.update(val, flipped)
	if flipped:
		tracker.empty_cups()
	else:
		tracker.fill_cups()
	return tracker.bonus() + val

func shuffle(safely):
	tracker.shuffle(safely)

func get_cups():
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_cups()
