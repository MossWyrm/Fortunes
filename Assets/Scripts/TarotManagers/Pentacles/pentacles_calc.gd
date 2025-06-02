extends card_calc
class_name pentacles_calc

@onready var tracker: pentacles_tracker = get_child(0)

func draw(card, flipped = false):
	if (card.card_default_value >= 0 && card.card_default_value <= 10):
		return _basic(card.card_default_value, flipped)
	elif card.card_default_value == 11:
		return _page(flipped)
	elif card.card_default_value == 12:
		return _knight(flipped)
	elif card.card_default_value == 13:
		return _queen(flipped)
	elif card.card_default_value == 14:
		return _king(flipped)
	else:
		print("Error finding pentacles card number")

func _value_modifier(value, flipped = false):
	return -value if flipped else value

func _basic(value, flipped = false):
	var val = _value_modifier(value, flipped)
	tracker.update(val, false)
	return tracker.current_pentacles+val

func _page(flipped = false):
	var val = _value_modifier(11, flipped)
	tracker.update(val, false)
	if flipped:
		tracker.current_pentacles = roundi(tracker.current_pentacles * 0.9)
	else:
		tracker.current_pentacles = roundi(tracker.current_pentacles * 1.1)
	return tracker.current_pentacles + val
	
func _knight(flipped = false):
	var val = _value_modifier(12, flipped)
	tracker.update(val, false)
	if flipped:
		tracker.adjust_charges(-Stats.pent_knight_uses)
	else:
		tracker.adjust_charges(Stats.pent_knight_uses)
	return tracker.current_pentacles + val

func _queen(flipped = false):
	tracker.update_queen_pentacles(flipped)
	
	var val = _value_modifier(13, flipped)
	tracker.update(val, false)
	
	return tracker.current_pentacles + val

func _king(flipped = false):
	var val = _value_modifier(14, flipped)
	tracker.update(val, false)
	if flipped:
		tracker.adjust_charges(0)
		tracker.update(0,false,true)
		tracker.blocked = true
	else:
		tracker.adjust_charges(Stats.pent_king_uses)
		tracker.update(Stats.pent_king_value, false, true)
		
	return tracker.current_pentacles + val

func shuffle(safely):
	tracker.shuffle(safely)

func use_pentacles(value):
	return tracker.use_pentacles(value)

func get_pentacles_display():
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_pentacles_display()

func check_queen_pent(flipped) -> bool:
	return tracker.use_queen_pentacles(flipped)
