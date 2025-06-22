extends Node
class_name Deck_Manager

@export var add_and_remove: AddRemove

## the live deck being modified
var active_deck: Array[Card] = []

## the current deck template
var selected_deck_list: Array[Card] = []

var all_cards: Dictionary[int,Card] = {}

signal _initialized

func _ready() -> void:
	GM.deck_manager = self
	Events.draw_card.connect(_draw_card)
	Events.unlock_card.connect(unlock_card)
	Events.shuffle.connect(shuffle)
	Events.reset_game.connect(reset)
	for child in self.get_children():
		all_cards[child.card_id_num] = child
	if selected_deck_list.is_empty():
		_build_deck()
	Events.emit_shuffle()
	_initialized.emit()

func debug_draw_major() -> void:
	var majors: Array[Card] = active_deck.filter(func(x: Card): return x.card_suit == ID.Suits.MAJOR)
	if majors.is_empty():
		print("No major found in deck")
		return
	Events.emit_selected_card(active_deck.pop_at(active_deck.find(majors.pop_at(randi() % majors.size()))), flip_check())
	
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
	Events.emit_save_request()

func get_deck_list() -> Array[Card]:
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
	add_and_remove.add_card(card)
	
func add_card_by_suit(suit: ID.Suits) -> void:
	var filtered: Array = all_cards.values().filter(func(x: Card): return (x.unlocked && x.card_suit == suit))
	add_card(filtered[randi() % filtered.size()].card_id_num)

func add_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = selected_deck_list.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	add_card(filtered[randi() % filtered.size()].card_id_num)
	
func remove_card(card_suit: ID.Suits = ID.Suits.NONE, card_id = 0) -> Card:
	var card: Card = null
	if card_suit == ID.Suits.NONE && card_id == 0:
		var random: int = randi() % active_deck.size()
		card = active_deck.pop_at(random)
	elif card_suit != ID.Suits.NONE && card_id == 0:
		var selection: Array[Variant] = active_deck.filter(func(x: Card): return x.card_suit == card_suit)
		if selection.size() <= 0:
			return
		var random: int = randi() % selection.size()
		card = active_deck.pop_at(active_deck.find(selection[random]))
	elif card_suit == 0 && card_id > 0:
		var index: int = active_deck.find_custom(func(x:Card): return x.card_id_num == card_id)
		if index >= 0:
			card = active_deck.pop_at(index)
	add_and_remove.remove_card(card)
	return card
	
	
func remove_all_copies(card_id: int) -> void:
	var copies: int = active_deck.filter(func(x: Card): return x.card_id_num == card_id).size()
	for x in copies:
		remove_card(ID.Suits.NONE, card_id)
	
func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
	var filtered: Array = active_deck.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
	remove_card(ID.Suits.NONE, filtered[randi() % filtered.size()].card_id_num)
#endregion
	
#region = "Save and Load"
func save_deck() -> Dictionary:
	var save_file := {}
	var unlock_status:= {}
	for card_id in all_cards.keys():
		unlock_status[card_id] = all_cards[card_id].unlocked
	save_file["unlock_status"] = unlock_status
	var current_deck := {}
	for card: Card in selected_deck_list:
		if current_deck.has(card.card_id_num):
			current_deck[card.card_id_num] += 1
		else:
			current_deck[card.card_id_num] = 1
	save_file["current_deck"] = current_deck
		
	return save_file

func load_deck(dict: Dictionary) -> void:
	if all_cards.is_empty():
		await _initialized
	for key in dict["unlock_status"]:
		all_cards[int(key)].unlocked = dict["unlock_status"][key]
	var new_deck: Array[Card]
	for key in dict["current_deck"]:
		for count in dict["current_deck"][key]:
			new_deck.append(get_card(int(key)))
	_select_deck(new_deck)
	
func reset() -> void:
	for key in all_cards.keys():
		all_cards[key].unlocked = all_cards[key].card_suit != ID.Suits.MAJOR
	_select_deck(get_default_deck())
	Events.emit_shuffle()
#endregion
