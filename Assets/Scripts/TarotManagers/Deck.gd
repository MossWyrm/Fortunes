extends Node
class_name Deck_Manager

## the live deck being modified
var active_deck: Array[Card] = []

## the current deck "return to default"
var selected_deck_list: Array[Card] = []

var children: Dictionary[int,Card] = {}

func _ready() -> void:
	GM.deck_manager = self
	Events.draw_card.connect(_draw_card)
	Events.unlock_card.connect(unlock_card)
	for child in self.get_children():
		children[child.card_id_num] = child
	if selected_deck_list.is_empty():
		_create_deck()
	_shuffle()

func _draw_card() -> void:
	if active_deck.size() <= 0:
		print("--- Shuffling ---")
		_shuffle()
	var random = randi() % active_deck.size()
	var output = active_deck.pop_at(random)
	var is_flipped = flip_check()
	Events.emit_selected_card(output, is_flipped)

func _create_deck():
	var output_deck: Array[Card] = []
	if selected_deck_list.is_empty():
		output_deck = get_default_deck()
		selected_deck_list.assign(output_deck)
	else:
		output_deck.assign(selected_deck_list)
	return output_deck

func get_default_deck() -> Array[Card]:
	var output_deck: Array[Card] = []
	for key in children.keys():
		if key >= 100 && key < 500:
			output_deck.append(children[key])
	return output_deck

func _shuffle() -> void:
	active_deck.clear()
	active_deck = _create_deck()
	Events.emit_shuffle()

func _select_deck(deck_list) -> void:
	if !deck_list.is_empty():
		selected_deck_list.assign(deck_list)
	else:
		print("Deck has no cards in dumdum!")
	# Shuffle may not be required when changing cards
	_shuffle()

func add_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = selected_deck_list.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	add_card(filtered[randi() % filtered.size()].card_id_num)

func add_card(card_id) -> void:
	var card: Node = children[card_id]
	if card == null:
		print("Card not found to add to deck: %s", card_id)
		return
	active_deck.append(card)

func unlock_card(card: Card) -> void:
	children[card.card_id_num].unlocked = true

func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = active_deck.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	remove_card(0, filtered[randi() % filtered.size()].card_id_num)
	
func remove_card(card_suit = 0, card_id = 0) -> void:
	if card_suit == 0 && card_id == 0:
		var random: int = randi() % active_deck.size()
		active_deck.remove_at(random)
	elif card_suit > 0 && card_id == 0:
		var selection: Array[Variant] = []
		var suit_id: int              = card_suit*100
		for _i in active_deck:
			if _i.card_id_num >= suit_id && _i.card_id_num < (suit_id +100):
				selection.append(_i)
		if selection.size() <= 0:
			return
		var random: int = randi() % selection.size()
		var index: int  = -1
		for _i in active_deck:
			if _i.card_id_num == selection[random].card_id_num:
				index = active_deck.find(_i)
				break
		if index >= 0:
			active_deck.remove_at(index)
	elif card_suit == 0 && card_id > 0:
		var index: int = -1
		for _i in active_deck:
			if _i.card_id_num == card_id:
				index = active_deck.find(_i)
				break
		if index > 1:
			active_deck.remove_at(index)

func _get_deck_list() -> Array[Card]:
	return selected_deck_list

func flip_check() -> bool:
	var random: float = randf()
	random += Stats.gen_inversion_chance_mod
	if random <= 0.5:
		return true
	return false

func get_all_cards() -> Array[Card]:
	return children.values()
