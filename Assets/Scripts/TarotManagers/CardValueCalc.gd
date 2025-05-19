extends Node
class_name CVC

@export var main: Node

@export var cups_node: Node
@export var wands_node: Node
@export var pentacles_node: Node
@export var swords_node: Node
@export var majors_node: Node

var current_currency: int = 0;

func _ready():
	Events.selected_card.connect(_calculate_card_value)
	Events.unlock_card.connect(_unlock_card)
	Events.shuffle.connect(_shuffle)
	Events.emit_update_currency_display(current_currency)
	
func _calculate_card_value(card, flipped = false):
	var card_val = 0
	if _pentacles_queen_check(flipped):
		flipped = !flipped
		pentacles_node._use_queen_pent()
	swords_node._update_swords(flipped)	
	if (card.card_id_num >= 100 && card.card_id_num < 200):
		card_val = _wand_knight_check() * cups_node._drawn_cup(card, flipped)
	elif (card.card_id_num >= 200 && card.card_id_num < 300):
		card_val = _wand_knight_check() * wands_node._drawn_wand(card, flipped)
	elif (card.card_id_num >= 300 && card.card_id_num < 400):
		card_val = _wand_knight_check() * pentacles_node._drawn_pentacle(card, flipped)
	elif (card.card_id_num >= 400 && card.card_id_num < 500):
		card_val = _wand_knight_check() * swords_node._drawn_sword(card, flipped)
	elif (card.card_id_num >= 500 && card.card_id_num < 600):
		card_val = _wand_knight_check() * majors_node._drawn_major(card, flipped)
	if card_val < 0 && pentacles_node._get_pentacles() > 0:
		card_val = pentacles_node._use_pentacles(card_val)
	_update_currency(card_val)
	Events.emit_update_suit_displays()
	# Events.emit_card_value(card_val)
	
func _update_currency(card_value):
	if current_currency + card_value <= 0:
		Events.emit_floating_text(0-current_currency)
	else:
		Events.emit_floating_text(card_value)
	current_currency += card_value
	if current_currency < 0:
		current_currency = 0
	Events.emit_update_currency_display(current_currency)
	Stats.current_currency = current_currency

func _remove_currency(val):
	var to_remove = -val
	_update_currency(to_remove)

func _add_card(val):
	self.get_parent().deck_manager._add_card(val)

func _remove_card(suit = 0, id = 0):
	self.get_parent().deck_manager._remove_card(suit, id)

func _get_deck_list():
	return self.get_parent().deck_manager._get_deck_list()

func _get_cups():
	return cups_node._get_cups()

func _get_wands():
	return wands_node._wand_bonus()

func _get_swords():
	return swords_node._get_swords_display()

func _get_pentacles():
	return pentacles_node._get_pentacles_display()

func _shuffle(safely):
	cups_node._shuffle(safely)
	wands_node._shuffle(safely)
	pentacles_node._shuffle(safely)

func _wand_knight_check():
	if wands_node._wand_knight_check():
		print("** Wand Knight Triggered **")
		return wands_node._wand_knight_multi()
	else:
		return 1

func _pentacles_queen_check(flipped):
	return pentacles_node._check_queen_pent(flipped)

func _unlock_card(card: Card):
	_update_currency(-card.unlock_cost)
