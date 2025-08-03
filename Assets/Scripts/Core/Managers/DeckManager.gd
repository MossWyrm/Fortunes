extends RefCounted
class_name DeckManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Deck data
var all_cards: Dictionary[int, DataStructures.Card] = {}
var default_deck: Array[DataStructures.Card] = []
var active_deck: Array[DataStructures.Card] = []
var selected_deck_list: Array[DataStructures.Card] = []

# Initialization state
var is_initialized: bool = false
signal initialization_signal

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()

func _connect_events():
	event_bus.deck_shuffled.connect(_on_deck_shuffled)

func initialize():
	if is_initialized:
		return
		
	_create_all_cards()
	_select_default_deck()
	is_initialized = true
	initialization_signal.emit()

func _create_all_cards():
	# Create all possible cards
	for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
		_create_suit_cards(suit)
	
	# Create Major Arcana cards
	_create_major_cards()

func _create_suit_cards(suit: DataStructures.SuitType):
	var base_id = _get_suit_base_id(suit)
	
	# Create numbered cards (1-10)
	for i in range(1, 11):
		var card_id = base_id + i
		var card = DataStructures.Card.new(card_id, suit, i)
		card.is_unlocked = true
		all_cards[card_id] = card
	
	# Create face cards (Page, Knight, Queen, King)
	var face_cards = [11, 12, 13, 14]  # Page, Knight, Queen, King
	for face_id in face_cards:
		var card_id = base_id + face_id
		var card = DataStructures.Card.new(card_id, suit, face_id)
		card.is_unlocked = true
		all_cards[card_id] = card

func _create_major_cards():
	var major_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
	var major_names = [
		"Fool", "Magician", "High Priestess", "Empress", "Emperor", "Hierophant",
		"Lovers", "Chariot", "Strength", "Hermit", "Wheel of Fortune", "Justice",
		"Hanged Man", "Death", "Temperance", "Devil", "Tower", "Star",
		"Moon", "Sun", "Judgement", "World"
	]
	
	for i in range(major_ids.size()):
		var card_id = 500 + major_ids[i]
		var card = DataStructures.Card.new(card_id, DataStructures.SuitType.MAJOR, major_ids[i])
		card.is_unlocked = false
		all_cards[card_id] = card

func _get_suit_base_id(suit: DataStructures.SuitType) -> int:
	match suit:
		DataStructures.SuitType.CUPS:
			return 100
		DataStructures.SuitType.WANDS:
			return 200
		DataStructures.SuitType.PENTACLES:
			return 300
		DataStructures.SuitType.SWORDS:
			return 400
		_:
			return 0

func _select_default_deck():
	selected_deck_list.clear()
	
	# Add one of each basic card
	for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
		var base_id = _get_suit_base_id(suit)
		for i in range(1, 15):  # 1-10 + Page, Knight, Queen, King
			var card_id = base_id + i
			if all_cards.has(card_id):
				selected_deck_list.append(all_cards[card_id])
	
	# Add Major Arcana cards (unlocked ones)
	for card_id in all_cards.keys():
		var card = all_cards[card_id]
		if card.suit == DataStructures.SuitType.MAJOR and card.is_unlocked:
			selected_deck_list.append(card)
	
	_build_active_deck()

func _build_active_deck():
	active_deck.clear()
	
	# Add cards based on their quantities in stats
	for card in selected_deck_list:
		var quantity = get_card_max_quantity(card)
		for i in range(quantity):
			active_deck.append(card.duplicate())
	
	shuffle_deck()

func get_card_max_quantity(card: DataStructures.Card) -> int:
	var stats = game_state.stats
	
	match card.suit:
		DataStructures.SuitType.CUPS:
			if card.value <= 10:
				return stats.cup_stats.basic_max_quantity
			else:
				return stats.cup_stats.face_max_quantity
		DataStructures.SuitType.WANDS:
			if card.value <= 10:
				return stats.wand_stats.basic_max_quantity
			else:
				return stats.wand_stats.face_max_quantity
		DataStructures.SuitType.PENTACLES:
			if card.value <= 10:
				return stats.pentacle_stats.basic_max_quantity
			else:
				return stats.pentacle_stats.face_max_quantity
		DataStructures.SuitType.SWORDS:
			if card.value <= 10:
				return stats.sword_stats.basic_max_quantity
			else:
				return stats.sword_stats.face_max_quantity
		DataStructures.SuitType.MAJOR:
			return stats.major_stats.quantity
		_:
			return 1

func draw_card() -> DataStructures.Card:
	if active_deck.is_empty():
		return null
	
	var card = active_deck.pop_front()
	var flipped = _should_flip_card()
	card.is_flipped = flipped
	
	event_bus.emit_card_drawn(card, flipped)
	event_bus.emit_deck_modified(DataStructures.DeckOperation.REMOVE, card)
	
	return card

func peek_card(index: int = 0) -> DataStructures.Card:
	if index >= active_deck.size():
		return null
	return active_deck[index]

func peek_multiple_cards(count: int) -> Array[DataStructures.Card]:
	var cards: Array[DataStructures.Card] = []
	for i in range(min(count, active_deck.size())):
		cards.append(active_deck[i])
	return cards

func shuffle_deck(safely: bool = false):
	active_deck.shuffle()
	event_bus.emit_deck_shuffled(safely)
	event_bus.emit_deck_modified(DataStructures.DeckOperation.SHUFFLE)

func add_card(card: DataStructures.Card):
	active_deck.append(card)
	event_bus.emit_deck_modified(DataStructures.DeckOperation.ADD, card)

func remove_card(card: DataStructures.Card):
	var index = active_deck.find(card)
	if index >= 0:
		active_deck.remove_at(index)
		event_bus.emit_deck_modified(DataStructures.DeckOperation.REMOVE, card)

func get_deck_size() -> int:
	return active_deck.size()

func is_deck_empty() -> bool:
	return active_deck.is_empty()

func _should_flip_card() -> bool:
	var stats = game_state.stats
	var base_chance = 0.5
	var modified_chance = base_chance + stats.inversion_chance_modifier
	return randf() < modified_chance

func _on_deck_shuffled(safely: bool):
	# Handle any shuffle-specific logic
	pass

func reset(reset_type: DataStructures.GameLayer):
	if reset_type >= DataStructures.GameLayer.DECK:
		# Reset card unlock status
		for card in all_cards.values():
			card.is_unlocked = false
		
		_select_default_deck()

func save() -> Dictionary:
	var save_data = {
		"unlock_status": {},
		"selected_deck": [],
		"active_deck": []
	}
	
	# Save unlock status
	for card_id in all_cards.keys():
		save_data["unlock_status"][str(card_id)] = all_cards[card_id].is_unlocked
	
	# Save selected deck
	for card in selected_deck_list:
		save_data["selected_deck"].append(card.id)
	
	# Save active deck
	for card in active_deck:
		save_data["active_deck"].append({
			"id": card.id,
			"flipped": card.is_flipped
		})
	
	return save_data

func load(data: Dictionary):
	if not data.has("unlock_status"):
		return
	
	# Load unlock status
	for card_id_str in data["unlock_status"].keys():
		var card_id = int(card_id_str)
		if all_cards.has(card_id):
			all_cards[card_id].is_unlocked = data["unlock_status"][card_id_str]
	
	# Load selected deck
	selected_deck_list.clear()
	if data.has("selected_deck"):
		for card_id in data["selected_deck"]:
			if all_cards.has(card_id):
				selected_deck_list.append(all_cards[card_id])
	
	# Load active deck
	active_deck.clear()
	if data.has("active_deck"):
		for card_data in data["active_deck"]:
			var card_id = card_data["id"]
			if all_cards.has(card_id):
				var card = all_cards[card_id].duplicate()
				card.is_flipped = card_data.get("flipped", false)
				active_deck.append(card)
	
	# If no active deck, build from selected deck
	if active_deck.is_empty():
		_build_active_deck() 