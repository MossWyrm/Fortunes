extends Node
class_name Deck_Manager

## the live deck being modified
var active_deck: Array[Card] = []

## the current deck "return to default"
var selected_deck_list: Array[Card] = []

var all_cards: Dictionary[int,Card] = {}

func _ready() -> void:
	GM.deck_manager = self
	Events.draw_card.connect(_draw_card)
	Events.unlock_card.connect(unlock_card)
	Events.shuffle.connect(shuffle)
	for child in self.get_children():
		all_cards[child.card_id_num] = child
	if selected_deck_list.is_empty():
		_build_deck()
	Events.emit_shuffle()

func _draw_card() -> void:
	if active_deck.is_empty():
		print("--- Shuffling ---")
		Events.emit_shuffle()
	var random: int = randi() % active_deck.size()
	Events.emit_selected_card(active_deck.pop_at(random), flip_check())

func _build_deck() -> Array[Card]:
	var output_deck: Array[Card] = []
	if selected_deck_list.is_empty():
		output_deck = get_default_deck()
		selected_deck_list.assign(output_deck)
	else:
		output_deck.assign(selected_deck_list)
	return output_deck

func get_default_deck() -> Array[Card]:
	var output_deck: Array[Card] = []
	for key in all_cards.keys():
		if key >= 100 && key < 500:
			output_deck.append(all_cards[key])
	return output_deck

func shuffle(_val = false) -> void:
	active_deck.clear()
	active_deck = _build_deck()

func _select_deck(deck_list) -> void:
	if !deck_list.is_empty():
		selected_deck_list.assign(deck_list)
	else:
		print("Deck has no cards in dumdum!")
	# Shuffle may not be required when changing cards
	Events.emit_shuffle()

func _get_deck_list() -> Array[Card]:
	return selected_deck_list

func flip_check() -> bool:
	var random: float = randf()
	random += Stats.gen_inversion_chance_mod
	if random <= 0.5:
		return true
	return false

func get_all_cards() -> Array[Card]:
	return all_cards.values()
	
func get_card(id: int) -> Card:
	return all_cards[id]
	
#region deck modification
func unlock_card(card: Card) -> void:
	all_cards[card.card_id_num].unlocked = true

func add_card(card_id: int) -> void:
	var card: Node = all_cards[card_id]
	if card == null:
		print("Card not found to add to deck: %s", card_id)
		return
	active_deck.append(card)
	
func add_card_by_suit(suit: ID.Suits) -> void:
	var filtered: Array = all_cards.values().filter(func(x: Card): return (x.unlocked && x.card_suit == suit))
	add_card(filtered[randi() % filtered.size()].card_id_num)

func add_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = selected_deck_list.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	add_card(filtered[randi() % filtered.size()].card_id_num)
	
func remove_card(card_suit: ID.Suits = ID.Suits.NONE, card_id = 0) -> Card:
	if card_suit == ID.Suits.NONE && card_id == 0:
		var random: int = randi() % active_deck.size()
		return active_deck.pop_at(random)
	elif card_suit != ID.Suits.NONE && card_id == 0:
		var selection: Array[Variant] = active_deck.filter(func(x: Card): return x.card_suit == card_suit)
		if selection.size() <= 0:
			return
		var random: int = randi() % selection.size()
		return active_deck.pop_at(active_deck.find(selection[random]))
	elif card_suit == 0 && card_id > 0:
		var index: int = active_deck.find_custom(func(x:Card): return x.card_id_num == card_id)
		if index > 0:
			return active_deck.pop_at(index)
	return null

func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = active_deck.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	remove_card(ID.Suits.NONE, filtered[randi() % filtered.size()].card_id_num)
#endregion

