extends Control
## Deck creator controller for managing card selection interface
##
## Handles the deck building interface, allowing players to add/remove cards
## from their deck while respecting deck size limits and card quantity restrictions.
## Integrates with the EventBus architecture for real-time updates.

#region Export Properties
@export var cups_panels_display: CardSelectBoxList
@export var wands_panels_display: CardSelectBoxList
@export var pentacles_panels_display: CardSelectBoxList
@export var swords_panels_display: CardSelectBoxList
@export var majors_panels_display: CardSelectBoxList
@export var deck_stats_display: DeckStats
#endregion

#region Node References & Data
@onready var panel_displays: Dictionary = {
	DataStructures.SuitType.CUPS: cups_panels_display,
	DataStructures.SuitType.WANDS: wands_panels_display,
	DataStructures.SuitType.PENTACLES: pentacles_panels_display,
	DataStructures.SuitType.SWORDS: swords_panels_display,
	DataStructures.SuitType.MAJOR: majors_panels_display
}

var all_cards: Array[Card] = []
#endregion

#region Computed Properties
var min_deck_size: int:
	get:
		if ValidationUtils.has_stats():
			return GameManager.game_state.stats.min_deck_size
		return 1  # Safe fallback

var max_deck_size: int:
	get:
		if ValidationUtils.has_stats():
			return GameManager.game_state.stats.max_deck_size
		return 100  # Safe fallback
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_layout()
	_setup_deck_creator()

# Connect to event bus and other signals
func _connect_signals() -> void:
	# Standard viewport signal connection
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	# Direct EventBus connection - always available as autoload
	EventBus.deck_modified.connect(_on_deck_modified)
	# EventBus.unlock_card.connect(_on_card_unlocked)  # When needed

# Initialize layout and positioning
func _initialize_layout() -> void:
	_update_position()

# Setup deck creator interface
func _setup_deck_creator() -> void:
	open_creator_menus()

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect all signals to prevent memory leaks
func _disconnect_signals() -> void:
	if get_viewport().size_changed.is_connected(_on_viewport_size_changed):
		get_viewport().size_changed.disconnect(_on_viewport_size_changed)
	
	if EventBus.deck_modified.is_connected(_on_deck_modified):
		EventBus.deck_modified.disconnect(_on_deck_modified)
	# if EventBus.unlock_card.is_connected(_on_card_unlocked):
	#     EventBus.unlock_card.disconnect(_on_card_unlocked)
#endregion

#region Layout Management
# Handle viewport size changes
func _on_viewport_size_changed() -> void:
	_update_position()

# Update panel position
func _update_position() -> void:
	position.x = 0
#endregion

#endregion

#region Data Access
# Get all available cards from deck manager
func get_all_cards() -> Array[Card]:
	if ValidationUtils.has_deck_manager():
		return GameManager.game_state.deck_manager.get_all_cards()
	return []

# Get the default deck from deck manager
func get_default_deck() -> Array[Card]:
	if ValidationUtils.has_deck_manager():
		return GameManager.game_state.deck_manager.get_default_deck()
	return []
#endregion

#region Deck Creator Interface
# Open deck creator UI and refresh displays
func open_creator_menus() -> void:
	if not visible:
		return
	
	all_cards = get_all_cards()
	_refresh_deck()
	_update_suits()
	_update_deck_stats()

# Refresh deck state from deck manager
func _refresh_deck() -> void:
	# Deck state is managed by deck_manager, no local state to refresh
	pass

# Update all suit displays
func _update_suits() -> void:
	for suit in panel_displays.keys():
		_display_suit(suit)

# Update deck statistics display
func _update_deck_stats() -> void:
	if not ValidationUtils.has_deck_manager():
		return
	
	var deck: Array[Card] = GameManager.game_state.deck_manager.selected_deck
	deck_stats_display.set_deck_stats(deck.size(), min_deck_size, max_deck_size)
#endregion

#region Event Handlers
# Handle card unlock events
# func _on_card_unlocked(_card: Card) -> void:
# 	_update_suits()

# Handle modifying the selected deck
func _on_deck_modified(operation: DataStructures.DeckOperation, card: Card) -> void:
	if ValidationUtils.has_deck_manager():
		if operation == DataStructures.DeckOperation.ADD:
			GameManager.game_state.deck_manager.add_card_to_selected(card)
		elif operation == DataStructures.DeckOperation.REMOVE:
			GameManager.game_state.deck_manager.remove_card_from_selected(card)
		_update_suits()
		_update_deck_stats()
#endregion

#endregion

#region Suit Display Management
# Update the display for all cards in a specific suit
func _display_suit(suit: int) -> void:
	var cards_in_suit: Array[Card] = _get_cards_for_suit(suit)
	if cards_in_suit.is_empty():
		return
	
	if not ValidationUtils.has_deck_manager():
		return
	
	var deck: Array[Card] = GameManager.game_state.deck_manager.get_deck_list()
	var deck_size: int = deck.size()
	var cards_of_suit_in_deck: int = _count_suit_cards_in_deck(deck, suit)
	
	for i in cards_in_suit.size():
		var card: Card = cards_in_suit[i]
		var card_count: int = deck.count(card)
		var addable: bool = _is_card_addable(card, card_count, suit, cards_of_suit_in_deck, deck_size)
		var removable: bool = _is_card_removable(card_count, deck_size)
		
		if i < panel_displays[suit].displays_list.size():
			panel_displays[suit].displays_list[i].update_display(card, addable, removable, card_count)

# Get all cards for a specific suit
func _get_cards_for_suit(suit: int) -> Array[Card]:
	var cards_in_suit: Array[Card] = []
	for card in all_cards:
		if card.suit == suit:
			cards_in_suit.append(card)
	return cards_in_suit

# Count how many cards of a specific suit are in the deck
func _count_suit_cards_in_deck(deck: Array[Card], suit: int) -> int:
	var count: int = 0
	if suit == DataStructures.SuitType.MAJOR:
		for card in deck:
			if card.suit == DataStructures.SuitType.MAJOR:
				count += 1
	return count
#endregion

#region Card Validation Logic
# Get the maximum quantity allowed for a specific card
func _get_card_max_quantity(card: Card, suit: int) -> int:
	if not ValidationUtils.has_stats():
		return 1
	
	var stats = GameManager.game_state.stats
	
	match suit:
		DataStructures.SuitType.MAJOR:
			return stats.major_stats.quantity
		DataStructures.SuitType.CUPS:
			return _get_suit_max_quantity(card, stats.cup_stats)
		DataStructures.SuitType.WANDS:
			return _get_suit_max_quantity(card, stats.wand_stats)
		DataStructures.SuitType.PENTACLES:
			return _get_suit_max_quantity(card, stats.pentacle_stats)
		DataStructures.SuitType.SWORDS:
			return _get_suit_max_quantity(card, stats.sword_stats)
		_:
			return 1

# Get max quantity for a card based on suit stats
func _get_suit_max_quantity(card: Card, suit_stats) -> int:
	if card.value > GameConstants.FACE_CARD_THRESHOLD:
		return suit_stats.face_max_quantity
	else:
		return suit_stats.basic_max_quantity

# Check if a card can be added to the deck
func _is_card_addable(card: Card, card_count: int, suit: int, cards_of_suit_in_deck: int, deck_size: int) -> bool:
	var max_quantity = _get_card_max_quantity(card, suit)
	
	if card_count >= max_quantity or deck_size >= max_deck_size:
		return false
	
	if suit == DataStructures.SuitType.MAJOR and cards_of_suit_in_deck >= max_quantity:
		return false
	
	return true

# Check if a card can be removed from the deck
func _is_card_removable(card_count: int, deck_size: int) -> bool:
	return card_count > 0 and deck_size > min_deck_size
#endregion


