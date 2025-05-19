extends Node

var child: Node

func _ready():
	child = get_child(0)

func _drawn_sword(card, flipped = false):
	if (card.card_default_value >= 0 && card.card_default_value <= 10):
		return _basic_sword(card.card_default_value, flipped)
	elif card.card_default_value == 11:
		return _page_sword(flipped)
	elif card.card_default_value == 12:
		return _knight_sword(flipped)
	elif card.card_default_value == 13:
		return _queen_sword(flipped)
	elif card.card_default_value == 14:
		return _king_sword(flipped)
	else:
		print("Error finding sword card number")

func _value_modifier(value, flipped = false):
	var updated_value: int = 0
	if flipped:
		updated_value = -value
	else:
		updated_value = value
	if child._get_page_status():
		updated_value = _use_page(updated_value)
	return updated_value

func _basic_sword(value, flipped = false):
	var val = _value_modifier(value, flipped)
	return _get_swords()*val

func _page_sword(flipped = false):
	var val = _value_modifier(11, flipped)
	child._page_triggered(flipped)
	return _get_swords()*val


func _knight_sword(flipped = false):
	var val = _value_modifier(12, flipped)
	var x = _get_swords()
	var deck_manager = self.get_parent()
	var deck = deck_manager._get_deck_list()

	while x > 0:
		if flipped:
			deck_manager._remove_card()
		else:
			var card_id = 0
			if deck.size() > 0:
				var random = randi() % deck.size()
				card_id = deck[random].card_id_num
				deck_manager._add_card(card_id)
			else:
				var random_suit = randi() % 4
				var random_card = randi() % 14
				deck_manager._add_card((random_suit*100)+random_card)
		x -= 1
	return _get_swords()*val

func _queen_sword(flipped = false):
	child._queen_triggered(flipped)
	var val = _value_modifier(13, flipped)
	return _get_swords()*val

func _king_sword(flipped = false):
	var val = _value_modifier(14, flipped)
	child._king_triggered(flipped)
	return _get_swords()*val

func _shuffle(safely):
	child._shuffle(safely)

func _get_swords():
	if child == null:
		child = get_child(0)
	return child._get_swords()

func _update_swords(flipped):
	if child == null:
		child = get_child(0)
	child._update_swords(flipped)

func _use_page(value):
	var output = value
	if child._page_type_upright():
		if value < 0:
			output = value ^ 1/_get_swords()
		else:
			output = value ^ _get_swords()
	else:
		if value < 0:
			output = value ^ _get_swords()
		else:
			output = value ^ 1/_get_swords()
	child._use_page()
	return output

func _get_swords_display():
	if child == null:
		child = get_child(0)
	return child._get_sword_display()
