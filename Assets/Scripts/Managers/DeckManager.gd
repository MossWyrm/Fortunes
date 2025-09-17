extends RefCounted
class_name DeckManager

var all_cards: Dictionary[int, Card] = {}
var starter_deck: Deck = Deck.new(self)
var active_deck: Deck = Deck.new(self)
var template_deck: Deck = Deck.new(self)

#region Initialization & Signals
var is_initialized: bool = false
signal initialization_signal
var game_state

## Sets the game state reference and connects event bus signals.
func set_game_state(state):
    if not ValidationUtils.validate_game_state(state):
        DebugManager.print_deck_operations("DeckManager: Invalid game state provided", DebugManager.DebugLevel.WARNING)
        return
    game_state = state
    # Connect to EventBus autoload
    EventBus.request_shuffle.connect(request_shuffle)
    EventBus.game_reset.connect(reset)
    initialize()

## Initializes deck data and emits initialization signal.
func initialize():
    if is_initialized:
        return
    _create_all_cards()
    _create_starter_deck()
    
    # Ensure we start with valid decks
    if template_deck.is_empty():
        template_deck = starter_deck.duplicate()
    if active_deck.is_empty():
        active_deck = template_deck.duplicate()
        active_deck.shuffle()
    
    is_initialized = true
    initialization_signal.emit()
    DebugManager.print_deck_operations("Deck Manager: Initialization complete")
#endregion

#region Card Initialization
## Creates all possible cards for each suit and major arcana.
func _create_all_cards():
    DebugManager.print_deck_operations("DeckManager: Creating all cards", DebugManager.DebugLevel.VERBOSE)
    for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
        DebugManager.print_deck_operations("DeckManager: Creating cards for suit %s" % suit, DebugManager.DebugLevel.VERBOSE)
        _create_suit_cards(suit)
    _create_major_cards()

## Creates numbered and face cards for a suit.
func _create_suit_cards(suit: DataStructures.SuitType):
    var base_id = _get_suit_base_id(suit)
    # Numbered cards (1-10)
    for i in range(1, 11):
        var card_id = base_id + i
        var card = Card.new(card_id, suit, i)
        card.is_unlocked = true
        all_cards[card_id] = card
    # Face cards (Page, Knight, Queen, King)
    var face_cards = [GameConstants.CARD_RANK_PAGE, GameConstants.CARD_RANK_KNIGHT, GameConstants.CARD_RANK_QUEEN, GameConstants.CARD_RANK_KING]
    for face_id in face_cards:
        var card_id = base_id + face_id
        var card = Card.new(card_id, suit, face_id)
        card.is_unlocked = true
        all_cards[card_id] = card

## Creates all major arcana cards.
func _create_major_cards():
    DebugManager.print_deck_operations("DeckManager: Creating major arcana cards", DebugManager.DebugLevel.VERBOSE)
    var major_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
    
    for i in range(major_ids.size()):
        var card_id = GameConstants.MAJOR_CARD_THRESHOLD + major_ids[i]
        var card = Card.new(card_id, DataStructures.SuitType.MAJOR)
        card.is_unlocked = false
        all_cards[card_id] = card
        
        var cost: int
        var card_number = major_ids[i]  # 1-22

        var foundation_exponent = 2.8
        var synergy_exponent = 2.5
        var power_exponent = 4.0
        var breaking_exponent = 7.0
        var ultimate_exponent = 28.0
        
        if card_number <= 5:
            # Foundation cards: Early game (500 - ~5K)
            cost = int(GameConstants.MAJOR_CARD_BASE_COST * pow(foundation_exponent, i))
        elif card_number <= 10:
            # Synergy cards: Moderate scaling (3.2K - 102K)
            var base_foundation = int(GameConstants.MAJOR_CARD_BASE_COST * pow(foundation_exponent, 5))
            cost = int(base_foundation * pow(synergy_exponent, i - 5))
        elif card_number <= 15:
            # Power cards: Strong scaling (409K - 13M)
            var base_synergy = int(GameConstants.MAJOR_CARD_BASE_COST * pow(synergy_exponent, 5) * pow(foundation_exponent, 5))
            cost = int(base_synergy * pow(power_exponent, i - 10))
        elif card_number <= 20:
            # Breaking cards: Exponential scaling (122M - 38B)
            var base_power = int(GameConstants.MAJOR_CARD_BASE_COST * pow(foundation_exponent,5)* pow(synergy_exponent, 5) * pow(power_exponent, 5))
            cost = int(base_power * pow(breaking_exponent, i - 15))
        else:
            # Ultimate cards: Universe-breaking scaling (953B - 596T)
            var base_breaking = int(GameConstants.MAJOR_CARD_BASE_COST * pow(foundation_exponent,5) * pow(synergy_exponent, 5) * pow(power_exponent, 5) * pow(breaking_exponent, 5))
            cost = int(base_breaking * pow(ultimate_exponent, i - 20))

        card.set_cost(cost)

        DebugManager.print_deck_operations("Major card %d cost: %s" % [card_number, Tools.get_shorthand(cost)], DebugManager.DebugLevel.VERBOSE)

## Returns the base card ID for a suit.
func _get_suit_base_id(suit: DataStructures.SuitType) -> int:
    match suit:
        DataStructures.SuitType.CUPS: return GameConstants.SUIT_OFFSET_CUPS
        DataStructures.SuitType.WANDS: return GameConstants.SUIT_OFFSET_WANDS
        DataStructures.SuitType.PENTACLES: return GameConstants.SUIT_OFFSET_PENTACLES
        DataStructures.SuitType.SWORDS: return GameConstants.SUIT_OFFSET_SWORDS
        DataStructures.SuitType.MAJOR: return GameConstants.MAJOR_CARD_THRESHOLD
        _: return 0

## Creates the starter deck from unlocked non-major cards.
func _create_starter_deck():
    starter_deck.clear()
    for card in all_cards.values():
        if card.suit != DataStructures.SuitType.MAJOR and card.is_unlocked:
            starter_deck.add_card(card.duplicate())
    DebugManager.print_deck_operations("DeckManager: Created starter deck. Deck size: %d" % starter_deck.size(), DebugManager.DebugLevel.VERBOSE)
#endregion

#region Deck Selection & Mutation
## Unlocks a card by ID
func unlock_card(card_id: int):
    var card = get_card(card_id)
    if card:
        card.is_unlocked = true

## Gets a card by ID from all_cards dictionary.
func get_card(card_id: int) -> Card:
    if all_cards.has(card_id):
        return all_cards[card_id]
    DebugManager.print_deck_operations("DeckManager: Card with ID %d not found" % card_id, DebugManager.DebugLevel.WARNING)
    return null

## Gets all available cards as an array.
func get_all_cards() -> Array[Card]:
    return all_cards.values()
#endregion

#region Live Deck Management
## Builds the active deck from the selected deck and shuffles.
func build_active_deck():
    active_deck = template_deck.duplicate()

## Shuffles the active deck and emits update.
func request_shuffle(safely: bool = false) -> void:
    _perform_shuffle(safely)

## Draws a card from the active deck, rebuilding if empty.
func draw_card() -> Card:
    return active_deck.draw_card()

## Handles the complete card drawing process including inversion calculation
func draw_and_emit_card() -> void:
    var card = draw_card()
    if not card:
        DebugManager.print_deck_operations("DeckManager: No card available to draw", DebugManager.DebugLevel.WARNING)
        return
    
    var is_flipped = _calculate_card_inversion()
    
    EventBus.emit_card_drawn(card, is_flipped)
    DebugManager.print_deck_operations("DeckManager: Emitted card_drawn for card %d in state %s" % [card.id, is_flipped])
    _shuffle_check()

func force_draw_card(card_id: int) -> void:
    var card = get_card(card_id)
    if active_deck.has_card(card):
        card = active_deck.remove_card(card)
    
    var is_flipped = randf() > 0.5
    EventBus.emit_card_drawn(card, is_flipped)
    DebugManager.print_deck_operations("DeckManager: Forced card_draw for card %d in state %s" % [card.id, is_flipped])
    _shuffle_check()
    
func _shuffle_check() -> void:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: Active deck empty after draw. Rebuilding and shuffling.", DebugManager.DebugLevel.VERBOSE)
        build_active_deck()
        EventBus.emit_request_shuffle(false)

## Internal method that performs the actual shuffle and notifications
func _perform_shuffle(safely: bool) -> void:
    active_deck.shuffle()
    
    # Always notify other systems that a shuffle has been completed
    EventBus.emit_shuffle_completed(safely)

## Calculates whether a card should be inverted based on game stats
func _calculate_card_inversion() -> bool:
    if not game_state or not game_state.stats:
        return false
    
    # Base inversion chance is 50%
    var random_chance = randf()
    var flipped = random_chance + game_state.stats.inversion_chance_modifier > 0.5
    DebugManager.print_deck_operations("DeckManager: Random Chance: %f. Result: %s" % [random_chance,flipped])
    return flipped

func reset(_tier: DataStructures.GameLayer) -> void:
    all_cards.clear()
    starter_deck.clear()
    active_deck.clear()
    template_deck.clear()
    is_initialized = false
    _create_all_cards()
    _create_starter_deck()
    template_deck = starter_deck.duplicate()
    active_deck = template_deck.duplicate()
    active_deck.shuffle()
#endregion

#region Live Deck Removals
## Removes a random card from the active deck.
func remove_random_card() -> Card:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: No card available to remove")
        return null
    var card = active_deck.remove_random_card()
    _request_remove_animation(card)
    DebugManager.print_deck_operations("DeckManager: Removed random card %d" % card.id, DebugManager.DebugLevel.VERBOSE)
    return card

## Removes a random non-major card from the active deck.
func remove_random_non_major_card() -> Card:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: No card available to remove")
        return null
    var card = active_deck.remove_random_non_major_card()
    if card:
        _request_remove_animation(card)
        DebugManager.print_deck_operations("DeckManager: Removed random non-major card %d" % card.id, DebugManager.DebugLevel.VERBOSE)
    return card

## Removes a specific card by ID from the active deck.
func remove_card_by_id(card_id: int) -> Card:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: No card available to remove")
        return null
    if active_deck.has_card(get_card(card_id)):
        DebugManager.print_deck_operations("DeckManager: Removed card %d" % card_id, DebugManager.DebugLevel.VERBOSE)
        var card = active_deck.remove_card(get_card(card_id))
        _request_remove_animation(card)
        return card
    DebugManager.print_deck_operations("DeckManager: Card %d not found in active deck" % card_id, DebugManager.DebugLevel.VERBOSE)
    return null

## Removes a random card of a specific suit from the active deck.
func remove_random_card_by_suit(suit) -> Card:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: No card available to remove")
        return null
    if active_deck.has_card_in_suit(suit):
        var card = active_deck.remove_random_card_by_suit(suit)
        _request_remove_animation(card)
        DebugManager.print_deck_operations("DeckManager: Removed random card of suit %s: %d" % [suit, card.id], DebugManager.DebugLevel.VERBOSE)
        return card
    DebugManager.print_deck_operations("DeckManager: No card of suit %s found in active deck" % suit, DebugManager.DebugLevel.VERBOSE)
    return null

## Removes a random card from the active deck with value lower than card_value (optionally including majors).
func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> Card:
    if active_deck.is_empty():
        DebugManager.print_deck_operations("DeckManager: No card available to remove")
        return null
    var card = active_deck.remove_lower_than(card_value, include_majors)
    if card:
        _request_remove_animation(card)
        DebugManager.print_deck_operations("DeckManager: Removed card lower than %d (include majors: %s): %d" % [card_value, include_majors, card.id if card else "No card found."], DebugManager.DebugLevel.VERBOSE)
        return card
    DebugManager.print_deck_operations("DeckManager: No card lower than %d found in active deck (include majors: %s)" % [card_value, include_majors], DebugManager.DebugLevel.VERBOSE)
    return null
#endregion

#region Live Deck Additions
## Adds a random unlocked card to the active deck.
func add_random_card() -> Card:
    var card = active_deck.add_random_card(true)
    _request_add_animation(card)
    return card

## Adds a random unlocked non-major card to the active deck.
func add_random_non_major_card() -> Card:
    var card = active_deck.add_random_card(false)
    _request_add_animation(card)
    return card

## Adds a random unlocked card of a specific suit to the active deck.
func add_random_card_by_suit(suit: DataStructures.SuitType) -> Card:
    var card = active_deck.add_random_card_by_suit(suit)
    _request_add_animation(card)
    return card

## Adds a specific unlocked card by ID to the active deck.
func add_card_by_id(card_id: int) -> Card:
    if all_cards.has(card_id) and all_cards[card_id].is_unlocked:
        var card = all_cards[card_id].duplicate()
        active_deck.add_card(card)
        _request_add_animation(card)
        return card
    return null

## Adds a random unlocked card with value lower than card_value (optionally including majors) to the active deck.
func add_lower_than(card_value: int = 0, include_majors: bool = false) -> Card:
    var card = active_deck.add_lower_than(card_value, include_majors)
    _request_add_animation(card)
    return card
#endregion

#region helper methods
func _request_remove_animation(card: Card) -> void:
    if card:
        EventBus.emit_request_deck_change_animation(DataStructures.DeckOperation.REMOVE, card)

func _request_add_animation(card: Card) -> void:
    if card:
        EventBus.emit_request_deck_change_animation(DataStructures.DeckOperation.ADD, card)

#endregion



#region Persistence
## Saves deck state to a dictionary.
func save() -> Dictionary:
    var save_data = {
        "unlock_status": {},
        "template_deck": [],
        "active_deck": []
    }
    # Save unlock status
    for card_id in all_cards.keys():
        save_data["unlock_status"][str(card_id)] = all_cards[card_id].is_unlocked
    # Save selected deck
    for card in template_deck.cards:
        save_data["template_deck"].append(card.id)
    # Save active deck
    for card in active_deck.cards:
        save_data["active_deck"].append(card.id)
    return save_data

## Loads deck state from a dictionary.
func load(data: Dictionary):
    DebugManager.print_file_operations("DeckManager: Loading deck state from save data...", DebugManager.DebugLevel.VERBOSE)
    if not data.has("unlock_status"):
        DebugManager.print_file_operations("DeckManager: No unlock status found in save data", DebugManager.DebugLevel.WARNING)
        return
    # Load unlock status
    for card_id_str in data["unlock_status"].keys():
        var card_id = int(card_id_str)
        if all_cards.has(card_id):
            all_cards[card_id].is_unlocked = data["unlock_status"][card_id_str]
    # Load selected deck
    var temp: Deck = Deck.new(self)
    if data.has("template_deck"):
        DebugManager.print_file_operations("DeckManager: Loading template deck...", DebugManager.DebugLevel.VERBOSE)
        for card_id in data["template_deck"]:
            var int_card_id = int(card_id)  # Ensure it's an integer
            if all_cards.has(int_card_id):
                temp.add_card(all_cards[int_card_id].duplicate())
    else:
        DebugManager.print_file_operations("DeckManager: No template deck found in save data", DebugManager.DebugLevel.VERBOSE)
        template_deck = starter_deck.duplicate()
    if temp.is_empty():
        DebugManager.print_file_operations("DeckManager: No valid cards found in template deck load data. Reverting to starter deck.", DebugManager.DebugLevel.WARNING)
        template_deck = starter_deck.duplicate()
    else:
        DebugManager.print_file_operations("DeckManager: Loaded template deck with %d cards" % temp.size(), DebugManager.DebugLevel.VERBOSE)
        template_deck = temp
    # Load active deck
    active_deck.clear()

    if data.has("active_deck"):
        DebugManager.print_file_operations("DeckManager: Loading active deck...", DebugManager.DebugLevel.VERBOSE)
        for card_id in data["active_deck"]:
            var int_card_id = int(card_id)  # Ensure it's an integer
            if all_cards.has(int_card_id):
                active_deck.add_card(all_cards[int_card_id].duplicate())
    # If no active deck, build from selected deck
    if active_deck.is_empty():
        DebugManager.print_file_operations("DeckManager: No valid cards found in active deck load data. Rebuilding from template deck.", DebugManager.DebugLevel.WARNING)
        active_deck = template_deck.duplicate()
    DebugManager.print_file_operations("DeckManager: Loaded active deck with %d cards" % active_deck.size(), DebugManager.DebugLevel.VERBOSE)
    active_deck.shuffle()
    DebugManager.print_file_operations("DeckManager: Load Complete", DebugManager.DebugLevel.VERBOSE)
#endregion