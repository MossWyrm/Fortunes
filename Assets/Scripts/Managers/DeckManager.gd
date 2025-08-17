extends RefCounted
class_name DeckManager

var all_cards: Dictionary[int, Card] = {}
var default_deck: Array[Card] = []
var active_deck: Array[Card] = []
var selected_deck: Array[Card] = []

#region Initialization & Signals
var is_initialized: bool = false
signal initialization_signal
signal deck_updated(deck_type: int)
var game_state

## Sets the game state reference and connects event bus signals.
func set_game_state(state):
    if not ValidationUtils.is_valid_game_state(state):
        push_error("DeckManager: Invalid game state provided")
        return
    game_state = state
    if ValidationUtils.has_event_bus():
        SignalManager.safe_connect(game_state.event_bus.request_shuffle, shuffle, "DeckManager request_shuffle")

## Initializes deck data and emits initialization signal.
func initialize():
    if is_initialized:
        return
    _create_all_cards()
    _create_default_deck()
    is_initialized = true
    initialization_signal.emit()
#endregion

#region Deck Creation
## Creates all possible cards for each suit and major arcana.
func _create_all_cards():
    for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
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
    var major_ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]
    var major_names = [
        "Fool", "Magician", "High Priestess", "Empress", "Emperor", "Hierophant",
        "Lovers", "Chariot", "Strength", "Hermit", "Wheel of Fortune", "Justice",
        "Hanged Man", "Death", "Temperance", "Devil", "Tower", "Star",
        "Moon", "Sun", "Judgement", "World"
    ]
    for i in range(major_ids.size()):
        var card_id = GameConstants.MAJOR_CARD_THRESHOLD + major_ids[i]
        var card = Card.new(card_id, DataStructures.SuitType.MAJOR, major_ids[i])
        card.is_unlocked = false
        all_cards[card_id] = card

## Returns the base card ID for a suit.
func _get_suit_base_id(suit: DataStructures.SuitType) -> int:
    match suit:
        DataStructures.SuitType.CUPS: return GameConstants.SUIT_OFFSET_CUPS
        DataStructures.SuitType.WANDS: return GameConstants.SUIT_OFFSET_WANDS
        DataStructures.SuitType.PENTACLES: return GameConstants.SUIT_OFFSET_PENTACLES
        DataStructures.SuitType.SWORDS: return GameConstants.SUIT_OFFSET_SWORDS
        _: return 0

## Creates the default deck from unlocked non-major cards.
func _create_default_deck():
    default_deck.clear()
    for card in all_cards.values():
        if card.suit != DataStructures.SuitType.MAJOR and card.is_unlocked:
            default_deck.append(card.duplicate())
#endregion

#region Deck Selection & Mutation
## Sets the selected deck and emits update.
func set_selected_deck(deck: Array[Card]):
    selected_deck = deck.duplicate()
    emit_signal("deck_updated", DataStructures.DeckType.SELECTED)

## Adds a card to the selected deck and emits update.
func add_card_to_selected(card: Card) -> void:
    selected_deck.append(card)
    emit_signal("deck_updated", DataStructures.DeckType.SELECTED)

## Removes a card from the selected deck and emits update.
func remove_card_from_selected(card: Card) -> void:
    selected_deck.erase(card)
    emit_signal("deck_updated", DataStructures.DeckType.SELECTED)

## Unlocks a card by ID and emits update.
func unlock_card(card_id: int):
    if all_cards.has(card_id):
        all_cards[card_id].is_unlocked = true
    emit_signal("deck_updated", DataStructures.DeckType.DEFAULT)
#endregion

#region Active Deck Management
## Builds the active deck from the selected deck and shuffles.
func build_active_deck():
    active_deck = selected_deck.duplicate()
    active_deck.shuffle()
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)

## Shuffles the active deck and emits update.
func request_shuffle(_safely: bool = false) -> void:
    active_deck.shuffle()
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)

## Draws a card from the active deck, rebuilding if empty.
func draw_card() -> Card:
    if active_deck.is_empty():
        build_active_deck()
    return active_deck.pop_front()
#endregion

#region Active Deck Mutation
## Removes a random card from the active deck.
func remove_random_card() -> Card:
    if active_deck.is_empty():
        return null
    var idx = randi() % active_deck.size()
    var card = active_deck[idx]
    active_deck.remove_at(idx)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card

## Removes a random non-major card from the active deck.
func remove_random_non_major_card() -> Card:
    if active_deck.is_empty():
        return null
    var non_major_cards = []
    for i in range(active_deck.size()):
        if active_deck[i].suit != DataStructures.SuitType.MAJOR:
            non_major_cards.append(i)
    if non_major_cards.size() == 0:
        return null
    var idx = non_major_cards[randi() % non_major_cards.size()]
    var card = active_deck[idx]
    active_deck.remove_at(idx)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card

## Removes a specific card by ID from the active deck.
func remove_card_by_id(card_id: int) -> Card:
    if active_deck.is_empty():
        return null
    for i in range(active_deck.size()):
        var card = active_deck[i]
        if card.id == card_id:
            active_deck.remove_at(i)
            emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
            return card
    return null

## Removes a random card of a specific suit from the active deck.
func remove_random_card_by_suit(suit) -> Card:
    if active_deck.is_empty():
        return null
    var suit_cards = []
    for i in range(active_deck.size()):
        if active_deck[i].suit == suit:
            suit_cards.append(i)
    if suit_cards.size() == 0:
        return null
    var idx = suit_cards[randi() % suit_cards.size()]
    var card = active_deck[idx]
    active_deck.remove_at(idx)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card
#endregion

#region Active Deck Additions
## Adds a random unlocked card to the active deck.
func add_random_card() -> Card:
    var unlocked = []
    for card in all_cards.values():
        if card.is_unlocked:
            unlocked.append(card)
    if unlocked.size() == 0:
        return null
    var card = unlocked[randi() % unlocked.size()].duplicate()
    active_deck.append(card)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card

## Adds a random unlocked non-major card to the active deck.
func add_random_non_major_card() -> Card:
    var unlocked = []
    for card in all_cards.values():
        if card.is_unlocked and card.suit != DataStructures.SuitType.MAJOR:
            unlocked.append(card)
    if unlocked.size() == 0:
        return null
    var card = unlocked[randi() % unlocked.size()].duplicate()
    active_deck.append(card)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card

## Adds a random unlocked card of a specific suit to the active deck.
func add_random_card_by_suit(suit) -> Card:
    var unlocked = []
    for card in all_cards.values():
        if card.is_unlocked and card.suit == suit:
            unlocked.append(card)
    if unlocked.size() == 0:
        return null
    var card = unlocked[randi() % unlocked.size()].duplicate()
    active_deck.append(card)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card

## Adds a specific unlocked card by ID to the active deck.
func add_card_by_id(card_id: int) -> Card:
    if all_cards.has(card_id) and all_cards[card_id].is_unlocked:
        var card = all_cards[card_id].duplicate()
        active_deck.append(card)
        emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
        return card
    return null

## Adds a random unlocked card with value lower than card_value (optionally including majors) to the active deck.
func add_lower_than(card_value: int = 0, include_majors: bool = false) -> Card:
    var filtered: Array = []
    for card in all_cards.values():
        if not card.is_unlocked:
            continue
        var value = card.value if card.has_method("get_value") else GameConstants.get_card_value_from_id(card.id)
        var is_major = card.suit == DataStructures.SuitType.MAJOR if card.has("suit") else card.id >= GameConstants.MAJOR_CARD_THRESHOLD
        if value < card_value and (include_majors or not is_major):
            filtered.append(card)
    if filtered.size() == 0:
        return null
    var chosen = filtered[randi() % filtered.size()].duplicate()
    active_deck.append(chosen)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return chosen
#endregion

#region Active Deck Removals
## Removes a random card from the active deck with value lower than card_value (optionally including majors).
func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> Card:
    var filtered: Array = []
    for i in range(active_deck.size()):
        var candidate = active_deck[i]
        var value = candidate.value if candidate.has_method("get_value") else GameConstants.get_card_value_from_id(candidate.id)
        var is_major = candidate.suit == DataStructures.SuitType.MAJOR if candidate.has("suit") else candidate.id >= GameConstants.MAJOR_CARD_THRESHOLD
        if value < card_value and (include_majors or not is_major):
            filtered.append(i)
    if filtered.size() == 0:
        return null
    var idx = filtered[randi() % filtered.size()]
    var card = active_deck[idx]
    active_deck.remove_at(idx)
    emit_signal("deck_updated", DataStructures.DeckType.ACTIVE)
    return card
#endregion

#region Persistence
## Saves deck state to a dictionary.
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
    for card in selected_deck:
        save_data["selected_deck"].append(card.id)
    # Save active deck
    for card in active_deck:
        save_data["active_deck"].append({
            "id": card.id,
            "flipped": card.is_flipped
        })
    return save_data

## Loads deck state from a dictionary.
func load(data: Dictionary):
    if not data.has("unlock_status"):
        return
    # Load unlock status
    for card_id_str in data["unlock_status"].keys():
        var card_id = int(card_id_str)
        if all_cards.has(card_id):
            all_cards[card_id].is_unlocked = data["unlock_status"][card_id_str]
    # Load selected deck
    selected_deck.clear()
    if data.has("selected_deck"):
        for card_id in data["selected_deck"]:
            if all_cards.has(card_id):
                selected_deck.append(all_cards[card_id])
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
        build_active_deck()
#endregion