extends Node
class_name CVC

@export var main: Node

@export var cups_node: cups_calc
@export var wands_node: card_calc
@export var pentacles_node: pentacles_calc
@export var swords_node: swords_calc
@export var majors_node: card_calc

var current_currency: int = 0;

func _ready():
	GM.cv_manager = self
	Events.selected_card.connect(_calculate_card_value)
	Events.unlock_card.connect(_unlock_card)
	Events.shuffle.connect(_shuffle)
	Events.emit_update_currency_display(current_currency)
	
func _calculate_card_value(card, flipped = false):
	var card_val = 0
	if _pentacles_queen_check(flipped):
		flipped = !flipped
	swords_node.update_swords(flipped)	
	if (card.card_id_num >= 100 && card.card_id_num < 200):
		card_val = _wand_knight_check() * cups_node.draw(card, flipped)
	elif (card.card_id_num >= 200 && card.card_id_num < 300):
		card_val = _wand_knight_check() * wands_node.draw(card, flipped)
	elif (card.card_id_num >= 300 && card.card_id_num < 400):
		card_val = _wand_knight_check() * pentacles_node.draw(card, flipped)
	elif (card.card_id_num >= 400 && card.card_id_num < 500):
		card_val = _wand_knight_check() * swords_node.draw(card, flipped)
	elif (card.card_id_num >= 500 && card.card_id_num < 600):
		card_val = _wand_knight_check() * majors_node.draw(card, flipped)
	if card_val < 0:
		card_val = pentacles_node.use_pentacles(card_val)
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

func add_card(id):
	GM.deck_manager._add_card(id)

func remove_card(suit: ResourceIDs.Suits, id = 0):
	GM.deck_manager._remove_card(suit, id)

func _get_deck_list():
	return GM.deck_manager._get_deck_list()

func _get_cups():
	return cups_node.get_cups()

func _get_wands():
	return wands_node._wand_bonus()

func _get_swords():
	return swords_node.get_swords_display()

func _get_pentacles():
	return pentacles_node.get_pentacles_display()

func _shuffle(safely):
	cups_node.shuffle(safely)
	wands_node._shuffle(safely)
	pentacles_node.shuffle(safely)

func _wand_knight_check():
	if wands_node._wand_knight_check():
		print("** Wand Knight Triggered **")
		return wands_node._wand_knight_multi()
	else:
		return 1

func _pentacles_queen_check(flipped):
	return pentacles_node.check_queen_pent(flipped)

func _unlock_card(card: Card):
	_update_currency(-card.unlock_cost)
