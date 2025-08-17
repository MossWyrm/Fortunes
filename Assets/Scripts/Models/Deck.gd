class_name Deck
extends RefCounted

var cards: Array[Card] = []

func add_card(card: Card):
    cards.append(card)

func remove_card(card: Card):
    var idx = cards.find(card)
    if idx >= 0:
        cards.remove_at(idx)

func shuffle():
    cards.shuffle()

func clear():
    cards.clear()

func duplicate() -> Deck:
    var new_deck = Deck.new()
    for card in cards:
        new_deck.cards.append(card.duplicate())
    return new_deck

func size() -> int:
    return cards.size()