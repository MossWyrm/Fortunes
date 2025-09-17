extends Control
class_name DeckCreator

## Deck creator controller for managing card selection interface
## Handles the deck building interface, allowing players to add/remove cards
## from their deck while respecting deck size limits and card quantity restrictions.

@export var cups_panels_display: DeckCreatorCardBoxList
@export var wands_panels_display: DeckCreatorCardBoxList
@export var pentacles_panels_display: DeckCreatorCardBoxList
@export var swords_panels_display: DeckCreatorCardBoxList
@export var majors_panels_display: DeckCreatorCardBoxList
@export var navigator: DeckCreatorNavigator
@export var deck_stats_display: DeckStats

@onready var panel_displays: Dictionary = {
	DataStructures.SuitType.CUPS: cups_panels_display,
	DataStructures.SuitType.WANDS: wands_panels_display,
	DataStructures.SuitType.PENTACLES: pentacles_panels_display,
	DataStructures.SuitType.SWORDS: swords_panels_display,
	DataStructures.SuitType.MAJOR: majors_panels_display
}

var deck_manager: DeckManager
var stats: GameStats

var saved_template: Deck
var template_deck: Deck:
	get:
		if template_deck == null:
			template_deck = deck_manager.template_deck.duplicate()
		return template_deck
var currently_active_suit: DataStructures.SuitType = DataStructures.SuitType.CUPS

var deck_manager_template: Deck:
	get:
		return deck_manager.template_deck
var min_deck_size: int:
	get:
		if ValidationUtils.has_stats():
			return GameManager.game_state.stats.min_deck_size
		return 1
var max_deck_size: int:
	get:
		if ValidationUtils.has_stats():
			return GameManager.game_state.stats.max_deck_size
		return 100
var all_cards: Array[Card]:
	get:
		if ValidationUtils.has_deck_manager():
			return deck_manager.get_all_cards()
		return []

func _ready() -> void:
	deck_manager = GameManager.game_state.deck_manager
	stats = GameManager.game_state.stats
	visibility_changed.connect(refresh_displays)
	EventBus.currency_updated.connect(_on_currency_updated)
	visibility_changed.connect(_on_visibility_changed)
	refresh_displays()
	GameManager.game_state.nav_manager.creator_panel = self
	navigator.deck_creator = self

#region Deck Creator Interface
# Open deck creator UI and refresh displays
func refresh_displays() -> void:
	if not visible:
		return
	_update_suits()
	_update_deck_stats()

# Update all suit displays
func _update_suits() -> void:
	for suit in panel_displays.keys():
		_display_suit(suit)

# Update deck statistics display
func _update_deck_stats() -> void:
	if not ValidationUtils.has_deck_manager():
		return
	var deck: Deck = template_deck
	deck_stats_display.set_deck_stats(deck.size(), min_deck_size, max_deck_size)
#endregion


#region Display Management
# Update the display for all cards in a specific suit
func _display_suit(suit: DataStructures.SuitType) -> void:
	var cards_in_suit: Array[Card] = _get_cards_in_suit(suit)
	if cards_in_suit.is_empty():
		DebugManager.print_card_management("DeckCreator: No cards found in suit " + str(suit), DebugManager.DebugLevel.WARNING)
		return
	
	for i in cards_in_suit.size():
		var card: Card = cards_in_suit[i]
		var data = DeckCreatorDisplayData.new(card, self)
		if i < panel_displays[suit].size():
			panel_displays[suit].get_display(i).update_display(data, self)

# Get all cards for a specific suit
func _get_cards_in_suit(suit: DataStructures.SuitType) -> Array[Card]:
	var cards_in_suit: Array[Card] = []
	for card in all_cards:
		if card.suit == suit:
			cards_in_suit.append(card)
	return cards_in_suit

# Count how many cards of a specific suit are in the deck
func _count_suit_cards_in_deck(deck: Array[Card], suit: DataStructures.SuitType) -> int:
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
	match suit:
		DataStructures.SuitType.MAJOR:
			return stats.major_stats.quantity_per_card
		DataStructures.SuitType.CUPS:
			return _get_individual_max_quantity(card, stats.cup_stats)
		DataStructures.SuitType.WANDS:
			return _get_individual_max_quantity(card, stats.wand_stats)
		DataStructures.SuitType.PENTACLES:
			return _get_individual_max_quantity(card, stats.pentacle_stats)
		DataStructures.SuitType.SWORDS:
			return _get_individual_max_quantity(card, stats.sword_stats)
		_:
			return 1

# Get max quantity for a card based on individual (face or basic) rules
func _get_individual_max_quantity(card: Card, suit_stats) -> int:
	if card.value > GameConstants.FACE_CARD_THRESHOLD:
		return suit_stats.face_max_quantity
	else:
		return suit_stats.basic_max_quantity
#endregion


#region Public Methods
func add_card_to_deck(card_id: int) -> void:
	template_deck.add_card(deck_manager.get_card(card_id))
	refresh_displays()

func remove_card_from_deck(card_id: int) -> void:
	template_deck.remove_card(deck_manager.get_card(card_id))
	refresh_displays()

func show_card_tooltip(card_id: int) -> void:
	EventBus.emit_tooltip_requested(deck_manager.get_card(card_id), DataStructures.GameLayer.DECK)

func purchase_card(card_id: int) -> void:
	if !can_afford(card_id):
		DebugManager.print_card_management("DeckCreator: Cannot afford card ID " + str(card_id))
		return
	var cost = get_card_cost(card_id)
	EventBus.emit_currency_updated(-cost, DataStructures.CurrencyType.CLAIRVOYANCE)
	deck_manager.unlock_card(card_id)
	refresh_displays()

func get_card_cost(card_id: int) -> int:
	var card = deck_manager.get_card(card_id)
	return card.cost

func can_afford(card_id: int) -> bool:
	return get_card_cost(card_id) <= stats.clairvoyance

func can_add_card(card_id: int) -> bool:
	var card: Card = deck_manager.get_card(card_id)
	var count_in_deck = template_deck.get_card_count(card)
	var max_quantity = _get_card_max_quantity(card, card.suit)
	if count_in_deck >= max_quantity:
		return false
	var cards_of_suit_in_deck = _count_suit_cards_in_deck(template_deck.cards, card.suit)
	if card.suit == DataStructures.SuitType.MAJOR and cards_of_suit_in_deck >= stats.major_stats.quantity_per_deck:
		return false
	return true

func can_remove_card(card_id: int) -> bool:
	var count_in_deck = template_deck.get_card_count(deck_manager.get_card(card_id))
	return count_in_deck > 0

func get_count_in_deck(card_id: int) -> int:
	return template_deck.get_card_count(deck_manager.get_card(card_id))
#endregion

#region Bulk Deck Operations
# Used to empty template deck
func clear_all_cards() -> void:
	template_deck.clear()
	refresh_displays()
	DebugManager.print_card_management("DeckCreator: Cleared entire deck")

# Used to remove all cards of a specific suit from deck
func clear_suit(suit: DataStructures.SuitType) -> void:
	var cards_to_remove: Array[Card] = []
	for card in template_deck.cards:
		if card.suit == suit:
			cards_to_remove.append(card)
	for card in cards_to_remove:
		template_deck.remove_card(card)
	refresh_displays()
	var suit_name = DataStructures.SuitType.keys()[suit].capitalize()
	DebugManager.print_card_management("DeckCreator: Cleared all %s cards" % suit_name)

# Used to add one copy of each basic card (1-King) from a suit if possible
func add_one_of_each_basic_suit(suit: DataStructures.SuitType) -> void:
	var basic_cards = _get_cards_in_suit(suit)
	basic_cards.sort_custom(func(x,y): return x.value > y.value)
	var added_count = 0
	
	for card in basic_cards:
		if can_add_card(card.id):
			template_deck.add_card(card)
			added_count += 1
	
	refresh_displays()
	var suit_name = DataStructures.SuitType.keys()[suit].capitalize()
	DebugManager.print_card_management("DeckCreator: Added %d basic %s cards" % [added_count, suit_name])

# Used to remove one copy of each basic card (1-King) from a suit if possible
func remove_one_of_each_basic_suit(suit: DataStructures.SuitType) -> void:
	var basic_cards = _get_cards_in_suit(suit)
	var removed_count = 0
	
	for card in basic_cards:
		if can_remove_card(card.id) and template_deck.has_card(card):
			template_deck.remove_card(card)
			removed_count += 1
	
	refresh_displays()
	var suit_name = DataStructures.SuitType.keys()[suit].capitalize()
	DebugManager.print_card_management("DeckCreator: Removed %d basic %s cards" % [removed_count, suit_name])

# Used to reset deck to the starter configuration
func reset_to_default_deck() -> void:
	if not ValidationUtils.has_deck_manager():
		return
	template_deck = deck_manager.starter_deck.duplicate()
	refresh_displays()
	DebugManager.print_card_management("DeckCreator: Reset to default starter deck")

# Used to add basic cards to reach minimum deck size
func auto_fill_to_minimum() -> void:
	var cards_needed = min_deck_size - template_deck.size()
	if cards_needed <= 0:
		return
	
	var available_cards: Array[Card] = []
	for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, 
				DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
					available_cards.append_array(_get_cards_in_suit(suit))
	var added_count = 0
	while added_count < cards_needed or template_deck.size() < min_deck_size:
		for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, 
					DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
			var suit_cards = available_cards.filter(func(x): return x.suit == suit)
			var card: Card = suit_cards[randi() % suit_cards.size()]
			if can_add_card(card.id):
				template_deck.add_card(card)
				added_count += 1
	refresh_displays()
	DebugManager.print_card_management("DeckCreator: Auto-filled %d cards to reach minimum" % added_count)
#endregion

#region Deck Validation
func is_deck_valid() -> bool:
	var deck_size = template_deck.size()
	return deck_size >= min_deck_size and deck_size <= max_deck_size

func get_deck_status_message() -> String:
	var deck_size = template_deck.size()
	if deck_size < min_deck_size:
		var needed = min_deck_size - deck_size
		return "Add %d more card%s to continue" % [needed, "s" if needed != 1 else ""]
	elif deck_size > max_deck_size:
		var excess = deck_size - max_deck_size
		return "Remove %d card%s to continue" % [excess, "s" if excess != 1 else ""]
	else:
		return "Deck is ready!"

func try_close_deck_creator() -> bool:
	if is_deck_valid():
		close_deck_creator()
		return true
	else:
		DebugManager.print_card_management("Cannot close: deck size invalid (%d cards)" % template_deck.size())
		return false

func close_deck_creator() -> void:
	if template_deck != saved_template:
		deck_manager_template = template_deck.duplicate()
		EventBus.emit_request_shuffle(false)
	hide()
#endregion

#region Event Handlers
func _on_currency_updated(_currency = null, _currency_type = null) -> void:
	refresh_displays()

func _on_visibility_changed() -> void:
	if visible:
		saved_template = template_deck.duplicate()

func _on_clear_suit_pressed() -> void:
	clear_suit(currently_active_suit)


func _on_plus_one_of_suit_pressed() -> void:
	add_one_of_each_basic_suit(currently_active_suit)

func _on_minus_one_of_suit_pressed() -> void:
	remove_one_of_each_basic_suit(currently_active_suit)
#endregion