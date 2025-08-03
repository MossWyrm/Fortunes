# extends Node
# class_name Deck_Manager

# @export var add_and_remove: AddRemove

# ## the live deck being modified
# var active_deck: Array[DataStructures.Card] = []

# ## the current deck template
# var selected_deck_list: Array[DataStructures.Card] = []

# var all_cards: Dictionary[int,DataStructures.Card] = {}

# signal _initialized

# func _ready() -> void:
# 	# Legacy compatibility - keep old GM reference
# 	GM.deck_manager = self
	
# 	# Connect to new architecture if available
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state:
# 		game_manager.game_state.deck_manager.set_deck_manager_reference(self)
# 		game_manager.game_state.event_bus.card_drawn.connect(_on_new_card_drawn)
# 		game_manager.game_state.event_bus.deck_shuffled.connect(_on_new_deck_shuffled)
	
# 	# Legacy event connections
# 	Events.draw_card.connect(_draw_card)
# 	Events.unlock_card.connect(unlock_card)
# 	Events.shuffle.connect(shuffle)
# 	Events.reset.connect(reset)
	
# 	for child in self.get_children():
# 		all_cards[child.card_id_num] = child
# 	if selected_deck_list.is_empty():
# 		_build_deck()
# 	Events.emit_shuffle()
# 	_initialized.emit()

# func _on_new_card_drawn(card: RefCounted):
# 	# Handle new architecture card drawn events
# 	pass

# func _on_new_deck_shuffled():
# 	# Handle new architecture deck shuffled events
# 	pass

# func debug_draw_major() -> void:
# 	var majors: Array[DataStructures.Card] = active_deck.filter(func(x: DataStructures.Card): return x.card_suit == DataStructures.SuitType.MAJOR)
# 	if majors.is_empty():
# 		print("No major found in deck")
# 		return
# 	Events.emit_selected_card(active_deck.pop_at(active_deck.find(majors.pop_at(randi() % majors.size()))), flip_check())

# # Debug method to test peek functionality
# func debug_test_peek() -> void:
# 	print("=== Testing Peek Functionality ===")
# 	print("Current deck size: ", active_deck.size())
	
# 	# Test peeking at first few cards
# 	var peeked_cards = peek_multiple_cards(5)
# 	print("Peeked at first 5 cards:")
# 	for i in range(peeked_cards.size()):
# 		var card = peeked_cards[i]
# 		print("  Card %d: ID=%d, Suit=%d" % [i, card.card_id_num, card.card_suit])
	
# 	print("Deck size after peek (should be same): ", active_deck.size())
	
# 	# Test simulating card logic
# 	if !peeked_cards.is_empty():
# 		var simulation = await simulate_card_logic(peeked_cards[0], false)
# 		print("Simulation results for first card:")
# 		print("  Base value: ", simulation["base_value"])
# 		print("  Main value: ", simulation["main_value"])
# 		print("  Post value: ", simulation["post_value"])
# 		print("  Final value: ", simulation["final_value"])
# 		print("  Clairvoyance change: ", simulation["clairvoyance_change"])
	
# 	print("=== End Test ===")
	
# func _draw_card() -> void:
# 	if active_deck.is_empty():
# 		print("--- Shuffling ---")
# 		Events.emit_shuffle()
	
# 	# Use new architecture if available
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
# 		if game_manager.game_state.game_stats.pause_drawing:
# 			return
# 	else:
# 		# Legacy fallback
# 		if Stats.pause_drawing:
# 			return
	
# 	var random: int = randi() % active_deck.size()
# 	var drawn_card = active_deck.pop_at(random)
# 	var flipped = flip_check()
	
# 	# Emit to new architecture if available
# 	if game_manager and game_manager.game_state:
# 		game_manager.game_state.event_bus.emit_card_drawn(drawn_card)
	
# 	# Legacy event emission
# 	Events.emit_selected_card(drawn_card, flipped)

# # New method: Draw a card without removing it from deck and without running logic
# func peek_card(index: int = 0) -> DataStructures.Card:
# 	if active_deck.is_empty():
# 		print("--- Shuffling ---")
# 		Events.emit_shuffle()
# 	if index >= active_deck.size():
# 		index = active_deck.size() - 1
# 	return active_deck[index]

# # New method: Draw a card without removing it from deck, but return a copy
# func peek_card_copy(index: int = 0) -> DataStructures.Card:
# 	var original_card = peek_card(index)
# 	# Create a copy of the card (assuming Card has a duplicate method or we can create a new instance)
# 	# For now, returning the original card reference - you may need to implement proper copying
# 	return original_card

# # New method: Run card logic without applying results (for simulation)
# func simulate_card_logic(card: DataStructures.Card, flipped: bool = false) -> Dictionary:
# 	# Store current state
# 	var original_deck_size = active_deck.size()
	
# 	# Temporarily disable currency updates
# 	var temp_pause = false
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
# 		temp_pause = game_manager.game_state.game_stats.pause_drawing
# 		game_manager.game_state.game_stats.pause_drawing = true
# 	else:
# 		# Legacy fallback
# 		temp_pause = Stats.pause_drawing
# 		Stats.pause_drawing = true
	
# 	# Use the comprehensive simulation method
# 	var simulation_result = await GM.cv_manager.simulate_card_calculation(card, flipped)
	
# 	# Restore drawing state
# 	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
# 		game_manager.game_state.game_stats.pause_drawing = temp_pause
# 	else:
# 		# Legacy fallback
# 		Stats.pause_drawing = temp_pause
	
# 	# Return simulation results
# 	return {
# 		"base_value": simulation_result["base_value"],
# 		"main_value": simulation_result["main_value"],
# 		"post_value": simulation_result["post_value"],
# 		"final_value": simulation_result["final_value"],
# 		"clairvoyance_change": simulation_result["clairvoyance_change"],
# 		"deck_size_change": original_deck_size - active_deck.size()
# 	}

# # New method: Draw and peek at multiple cards without running logic
# func peek_multiple_cards(count: int) -> Array[DataStructures.Card]:
# 	var cards: Array[DataStructures.Card] = []
# 	for i in range(min(count, active_deck.size())):
# 		cards.append(peek_card(i))
# 	return cards

# # New method: Draw a card without running the full calculation logic
# func draw_card_without_logic() -> DataStructures.Card:
# 	if active_deck.is_empty():
# 		print("--- Shuffling ---")
# 		Events.emit_shuffle()
	
# 	# Use new architecture if available
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
# 		if game_manager.game_state.game_stats.pause_drawing:
# 			return null
# 	else:
# 		# Legacy fallback
# 		if Stats.pause_drawing:
# 			return null
	
# 	var random: int = randi() % active_deck.size()
# 	return active_deck.pop_at(random)

# func _build_deck() -> Array[DataStructures.Card]:
# 	var output_deck: Array[DataStructures.Card] = []
# 	if selected_deck_list.is_empty():
# 		output_deck = get_default_deck()
# 		selected_deck_list.assign(output_deck)
# 	else:
# 		output_deck.assign(selected_deck_list)
# 	return output_deck

# func get_default_deck() -> Array[DataStructures.Card]:
# 	var output_deck: Array[DataStructures.Card] = []
# 	for key in all_cards.keys():
# 		if key >= 100 && key < 500:
# 			output_deck.append(all_cards[key])
# 	return output_deck

# func shuffle(_val = false) -> void:
# 	active_deck.clear()
# 	active_deck = _build_deck()
	
# 	# Emit to new architecture if available
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state:
# 		game_manager.game_state.event_bus.emit_deck_shuffled()

# func _select_deck(deck_list) -> void:
# 	if !deck_list.is_empty():
# 		selected_deck_list.assign(deck_list)
# 	else:
# 		print("Deck has no cards in dumdum!")
# 	# Shuffle may not be required when changing cards
# 	Events.emit_shuffle()
# 	Events.emit_save_request()

# func get_deck_list() -> Array[DataStructures.Card]:
# 	return selected_deck_list

# func flip_check() -> bool:
# 	var random: float = randf()
	
# 	# Use new architecture if available
# 	var game_manager = get_node("/root/GameManager")
# 	if game_manager and game_manager.game_state and game_manager.game_state.game_stats:
# 		random += game_manager.game_state.game_stats.gen_inversion_chance_mod
# 	else:
# 		# Legacy fallback
# 		random += Stats.gen_inversion_chance_mod
	
# 	if random <= 0.5:
# 		return true
# 	return false

# func get_all_cards() -> Array[DataStructures.Card]:
# 	return all_cards.values()
	
# func get_card(id: int) -> DataStructures.Card:
# 	return all_cards[id]
	
# #region deck modification
# func unlock_card(card: DataStructures.Card) -> void:
# 	all_cards[card.card_id_num].unlocked = true
# 	if card.card_id_num == 522:
# 		Events.emit_pack_complete()

# func add_card(card_id: int) -> void:
# 	var card: Node = all_cards[card_id]
# 	if card == null:
# 		print("Card not found to add to deck: %s", card_id)
# 		return
# 	active_deck.append(card)
# 	add_and_remove.add_card(card)
	
# func add_card_by_suit(suit: DataStructures.SuitType) -> void:
# 	var filtered: Array = all_cards.values().filter(func(x: DataStructures.Card): return (x.unlocked && x.card_suit == suit))
# 	add_card(filtered[randi() % filtered.size()].card_id_num)

# func add_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
# 	var filtered: Array = selected_deck_list.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
# 	add_card(filtered[randi() % filtered.size()].card_id_num)
	
# func remove_card(card_suit: DataStructures.SuitType = DataStructures.SuitType.NONE, card_id = 0) -> DataStructures.Card:
# 	var card: DataStructures.Card = null
# 	if card_suit == DataStructures.SuitType.NONE && card_id == 0:
# 		var random: int = randi() % active_deck.size()
# 		card = active_deck.pop_at(random)
# 	elif card_suit != DataStructures.SuitType.NONE && card_id == 0:
# 		var selection: Array[Variant] = active_deck.filter(func(x: DataStructures.Card): return x.card_suit == card_suit)
# 		if selection.size() <= 0:
# 			return
# 		var random: int = randi() % selection.size()
# 		card = active_deck.pop_at(active_deck.find(selection[random]))
# 	elif card_suit == 0 && card_id > 0:
# 		var index: int = active_deck.find_custom(func(x:DataStructures.Card): return x.card_id_num == card_id)
# 		if index >= 0:
# 			card = active_deck.pop_at(index)
# 	add_and_remove.remove_card(card)
# 	return card
	
	
# func remove_all_copies(card_id: int) -> void:
# 	var copies: int = active_deck.filter(func(x: DataStructures.Card): return x.card_id_num == card_id).size()
# 	for x in copies:
# 		remove_card(DataStructures.SuitType.NONE, card_id)
	
# func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> void:
# 	var filtered: Array = active_deck.filter(func(x): return (x.card_id_num % 100 < card_value && (include_majors || x.card_id_num < 500)))
# 	remove_card(DataStructures.SuitType.NONE, filtered[randi() % filtered.size()].card_id_num)
# #endregion
	
# #region = "Save and Load"
# func save_deck() -> Dictionary:
# 	var save_file := {}
# 	var unlock_status:= {}
# 	for card_id in all_cards.keys():
# 		unlock_status[card_id] = all_cards[card_id].unlocked
# 	save_file["unlock_status"] = unlock_status
# 	var current_deck := {}
# 	for card: DataStructures.Card in selected_deck_list:
# 		if current_deck.has(card.card_id_num):
# 			current_deck[card.card_id_num] += 1
# 		else:
# 			current_deck[card.card_id_num] = 1
# 	save_file["current_deck"] = current_deck
		
# 	return save_file

# func load_deck(dict: Dictionary) -> void:
# 	if all_cards.is_empty():
# 		await _initialized
# 	for key in dict["unlock_status"]:
# 		all_cards[int(key)].unlocked = dict["unlock_status"][key]
# 	var new_deck: Array[DataStructures.Card]
# 	for key in dict["current_deck"]:
# 		for count in dict["current_deck"][key]:
# 			new_deck.append(get_card(int(key)))
# 	_select_deck(new_deck)
	
# func reset(type: DataStructures.GameLayer) -> void:
# 	if type >= DataStructures.GameLayer.DECK:
# 		for key in all_cards.keys():
# 			all_cards[key].unlocked = all_cards[key].card_suit != DataStructures.SuitType.MAJOR
# 		_select_deck(get_default_deck())
# 		Events.emit_shuffle()
# #endregion
