extends Node

var child: Node
var wand_page_active = false
var wand_page_positive = false
var wand_knight_active = false
var wand_knight_positive = false
var queen_effect_active = false
var queen_effect_positive = false

func _ready():
	child = get_child(0)

func _drawn_wand(card, flipped = false):
	if _page_check() && !wand_page_positive:
		print("Page has caused 0 increase in moneys!")
		return 0
	elif (card.card_default_value >= 0 && card.card_default_value <= 10):
		return _basic_wand(card.card_default_value, flipped)
	elif card.card_default_value == 11:
		return _page_wand(flipped)
	elif card.card_default_value == 12:
		return _knight_wand(flipped)
	elif card.card_default_value == 13:
		return _queen_wand(flipped)
	elif card.card_default_value == 14:
		return _king_wand(flipped)
	else:
		print("Error finding wand card number")

func _value_modifier(value, flipped = false):
	var updated_value: int = 0
	var queen_mod = 0
	if queen_effect_active:
		if queen_effect_positive:
			queen_mod = 1
		else:
			queen_mod = -1
		queen_effect_active = false
	else:
		queen_mod = 0

	if flipped:
		updated_value = -value
	else:
		updated_value = value
	return updated_value + queen_mod

func _basic_wand(value, flipped = false):
	var val = _value_modifier(value + Stats.wand_basic_value, flipped)
	var multi = 1
	if _page_check():
		multi = 2
	else:
		multi = 1
	child._update_wand((val / 100.0)* multi)

	return (val * child._wand_bonus())*multi

func _page_wand(flipped = false):
	var val = _value_modifier(11, flipped)
	if flipped:
		wand_page_active = true
		wand_page_positive = false
	return (val) * child._wand_bonus()

func _page_check():
	if wand_page_active:
		wand_page_active = false
		return true
	else:
		return false

func _knight_wand(flipped = false):
	var val = _value_modifier(12, flipped)
	wand_knight_active = true
	if flipped:
		wand_knight_positive = false
	else:
		wand_knight_positive = true
	return (val) * child._wand_bonus()

func _queen_wand(flipped = false):
	var val = _value_modifier(13, flipped)
	queen_effect_active = true		

	if flipped:
		queen_effect_positive = false
	else:
		queen_effect_positive = true
	
	return (val) * child._wand_bonus()

func _king_wand(flipped = false):
	var val = _value_modifier(14, flipped)
	child._king_wand_mod(flipped)
	return (val) * child._wand_bonus()

func _shuffle(safely):
	child._shuffle(safely)

func _wand_bonus():
	if child == null:
		child = get_child(0)
	return child._wand_bonus()

func _wand_knight_check():
	if wand_knight_active:
		wand_knight_active = false
		return true
	else:
		return false

func _wand_knight_multi():
	if wand_knight_positive:
		return child._wand_bonus()
	else:
		return 1/child._wand_bonus()
