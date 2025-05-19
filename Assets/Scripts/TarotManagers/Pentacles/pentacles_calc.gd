extends Node

var child: Node

func _ready():
	child = get_child(0)

func _drawn_pentacle(card, flipped = false):
	if (card.card_default_value >= 0 && card.card_default_value <= 10):
		return _basic_pent(card.card_default_value, flipped)
	elif card.card_default_value == 11:
		return _page_pent(flipped)
	elif card.card_default_value == 12:
		return _knight_pent(flipped)
	elif card.card_default_value == 13:
		return _queen_pent(flipped)
	elif card.card_default_value == 14:
		return _king_pent(flipped)
	else:
		print("Error finding cup card number")

func _value_modifier(value, flipped = false):
	var updated_value: int = 0
	if flipped:
		updated_value = -value
	else:
		updated_value = value
	return updated_value

func _basic_pent(value, flipped = false):
	var val = _value_modifier(value, flipped)
	child._update_pentacle(val, false)
	return _get_pentacles()+val

func _page_pent(flipped = false):
	var pent_val : float = _get_pentacles()
	var val = _value_modifier(11, flipped)
	child._update_pentacle(val, false)
	if flipped:
		pent_val *= 0.9
	else:
		pent_val *= 1.1
	child._replace_pentacles(pent_val)
	return _get_pentacles() + val


func _knight_pent(flipped = false):
	var val = _value_modifier(12, flipped)
	child._update_pentacle(val, false)
	if flipped:
		child._update_pentacle(-1,true)
	else:
		child._update_pentacle(1,true)
	return _get_pentacles() + val

func _queen_pent(flipped = false):
	if flipped:
		child._update_queen_pentacles(-1)
	else:
		child._update_queen_pentacles(1)
	
	var val = _value_modifier(13, flipped)
	child._update_pentacle(val, false)
	
	return _get_pentacles() + val

func _king_pent(flipped = false):
	var val = _value_modifier(14, flipped)
	child._update_pentacle(val, false)

	print("pent king not implemented")
		
	return _get_pentacles() + val

func _shuffle(safely):
	child._shuffle(safely)

func _get_pentacles():
	if child == null:
		child = get_child(0)
	return child._get_pentacles()

func _use_pentacles(value):
	return child._use_pentacles(value)

func _get_pentacles_display():
	if child == null:
		child = get_child(0)
	return child._get_pentacles_display()

func _check_queen_pent(flipped):
	return child._check_queen_pentacles(flipped)

func _use_queen_pent():
	child._use_queen_pentacles()
