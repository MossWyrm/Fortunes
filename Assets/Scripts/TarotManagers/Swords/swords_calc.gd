extends card_calc
class_name swords_calc

@onready var tracker: swords_tracker = get_child(0)

func draw(card: Card, flipped = false) -> int:
	match card.card_default_value:
		11:
			return _page(flipped)
		12:
			return _knight(flipped)
		13:
			return _queen(flipped)
		14:
			return _king(flipped)
		_:
			return _basic(card.card_default_value, flipped)

func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = -value if flipped else value
	updated_value = _use_page(updated_value)
	return updated_value

func _basic(value, flipped = false) -> int:
	var val = _value_modifier(value, flipped)
	return tracker.get_swords()*val

func _page(flipped = false) -> int:
	var val = _value_modifier(11, flipped)
	tracker.page_triggered(flipped)
	return tracker.get_swords()*val


func _knight(flipped = false) -> int:
	var val = _value_modifier(12, flipped)
	var x = tracker.get_swords()
	var deck_manager = GM.deck_manager
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
	return tracker.get_swords()*val

func _queen(flipped = false) -> int:
	tracker.queen_triggered(flipped)
	var val = _value_modifier(13, flipped)
	return tracker.get_swords()*val

func _king(flipped = false) -> int:
	var val = _value_modifier(14, flipped)
	tracker.king_triggered(flipped)
	return tracker.get_swords()*val

func _shuffle(safely) -> void:
	tracker.shuffle(safely)

func update_swords(flipped) -> void:
	if tracker == null:
		tracker = get_child(0)
	tracker.update(0,flipped)

func _use_page(value):
	if !tracker.get_page_status():
		return value
	var output = value
	if tracker.page_type_upright():
		if value < 0:
			output = value ^ 1/ tracker.get_swords()
		else:
			output = value ^ tracker.get_swords()
	else:
		if value < 0:
			output = value ^ tracker.get_swords()
		else:
			output = value ^ 1/ tracker.get_swords()
	tracker.use_page()
	return output

func get_swords_display():
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_sword_display()
