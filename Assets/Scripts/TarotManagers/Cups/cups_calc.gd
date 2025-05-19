extends Node

var child: Node

func _ready():
	child = get_child(0)

func _drawn_cup(card, flipped = false):
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
	child._update_cup(val)
	return child._cup_bonus() + val

func _page_cup(flipped = false):
	if flipped:
		return 0;
	else:
		return 0;

func _knight_cup(flipped = false):
	var val = _value_modifier(12, flipped)
	child._update_cup(val)
	var random_num = randi() % 14 + 101
	if flipped:
		self.get_parent()._remove_card(1,0)
	else:
		self.get_parent()._add_card(random_num)
	return child._cup_bonus() + val

func _queen_cup(flipped = false):
	if flipped:
		child._remove_cup()
	else:
		child._add_cup()
	
	var val = _value_modifier(13)
	child._update_cup(val)
	
	return child._cup_bonus() + val

func _king_cup(flipped = false):
	var val = _value_modifier(14)
	child._update_cup(val)
	if flipped:
		child._empty_cups()
	else:
		child._fill_cups()
	return child._cup_bonus() + val

func _shuffle(safely):
	child._shuffle(safely)

func _get_cups():
	if child == null:
		child = get_child(0)
	return child._get_cups()
