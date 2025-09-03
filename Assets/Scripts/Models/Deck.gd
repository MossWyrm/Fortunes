class_name Deck
extends RefCounted

var cards: Array[Card] = []
var deck_manager: DeckManager

#region Initialization
func _init(mgr: DeckManager) -> void:
    deck_manager = mgr
    DebugManager.print_deck_operations("Deck: Initialized with DeckManager", DebugManager.DebugLevel.VERBOSE)

func add_card(card: Card) -> void:
    cards.append(card)
#endregion

#region AddCards
func add_random_card(include_majors: bool) -> Card:
    var card = deck_manager.get_random_card(include_majors, true)
    if card:
        add_card(card)
        return card
    return null

func add_random_card_by_suit(suit: DataStructures.SuitType) -> Card:
    var unlocked = _get_unlocked_cards()
    var suit_cards = []
    for card in unlocked:
        if card.suit == suit:
            suit_cards.append(card)
    if suit_cards.size() == 0:
        return null
    var card = suit_cards[randi() % suit_cards.size()].duplicate()
    add_card(card)
    return card

func add_lower_than(card_value: int, include_majors: bool = false) -> Card:
    var filtered: Array = []
    for card in _get_unlocked_cards():
        var value = card.value
        var is_major = card.suit == DataStructures.SuitType.MAJOR
        if value < card_value and (include_majors or not is_major):
            filtered.append(card)
    if filtered.size() == 0:
        return null
    var chosen = filtered[randi() % filtered.size()].duplicate()
    add_card(chosen)
    return chosen
#endregion

#region RemoveCards
func remove_card(card: Card) -> Card:
    var idx = _find_card(card)
    if idx != -1:
        return cards.pop_at(idx)
    return null

func remove_random_card() -> Card:
    if cards.size() == 0:
        return null
    var idx = randi() % cards.size()
    return cards.pop_at(idx)

func remove_random_non_major_card() -> Card:
    var non_major_cards = []
    for i in range(cards.size()):
        var card = cards[i]
        if card.suit != DataStructures.SuitType.MAJOR:
            non_major_cards.append(card)
    if non_major_cards.size() == 0:
        return null
    var idx = randi() % non_major_cards.size()
    return cards.pop_at(_find_card(non_major_cards[idx]))

func remove_random_card_by_suit(suit: DataStructures.SuitType) -> Card:
    var cards_of_suit = []
    for card in cards:
        if card.suit == suit:
            cards_of_suit.append(card)
    if cards_of_suit.size() == 0:
        return null
    var idx = randi() % cards_of_suit.size()
    return cards.pop_at(_find_card(cards_of_suit[idx]))

func remove_lower_than(card_value: int = 0, include_majors: bool = false) -> Card:
    var filtered: Array = []
    for card in cards:
        var value = card.value
        var is_major = card.suit == DataStructures.SuitType.MAJOR
        if value < card_value and (include_majors or not is_major):
            filtered.append(card)
    if filtered.size() == 0:
        return null
    return remove_card(filtered[randi() % filtered.size()])
#endregion

#region Utility
func draw_card() -> Card:
    if cards.size() == 0:
        return null
    return cards.pop_front()

func has_card(card: Card) -> bool:
    if _find_card(card) != -1:
        return true
    return false

func get_card_count(card: Card) -> int:
    var count: int = 0
    for c in cards:
        if c.id == card.id:
            count += 1
    return count

func shuffle() -> void:
    cards.shuffle()

func clear() -> void:
    cards.clear()

func duplicate() -> Deck:
    var new_deck = Deck.new(deck_manager)
    for card in cards:
        new_deck.add_card(card.duplicate())
    return new_deck

func size() -> int:
    return cards.size()

func is_empty() -> bool:
    return size() <= 0
#endregion

#region Private Methods
func _find_card(card: Card) -> int:
    for i in range(cards.size()):
        if cards[i].id == card.id:
            return i
    return -1

func _get_random_card(include_majors: bool = false, unlocked_only: bool = true) -> Card:
    var candidates = []
    var selection_pool = _get_unlocked_cards() if unlocked_only else deck_manager.all_cards.values()
    for card in selection_pool:
        if include_majors or card.suit != DataStructures.SuitType.MAJOR:
            candidates.append(card)
    if candidates.size() == 0:
        return null
    return candidates[randi() % candidates.size()]

func _get_random_card_by_suit(unlocked_only: bool = true) -> Card:
    var candidates = []
    var selection_pool = _get_unlocked_cards() if unlocked_only else deck_manager.all_cards.values()
    for card in selection_pool:
        if card.suit == DataStructures.SuitType.MAJOR:
            candidates.append(card)
    if candidates.size() == 0:
        return null
    return candidates[randi() % candidates.size()]

func _get_unlocked_cards() -> Array:
    var unlocked = []
    for card in deck_manager.all_cards.values():
        if card.is_unlocked:
            unlocked.append(card)
    return unlocked
#endregion