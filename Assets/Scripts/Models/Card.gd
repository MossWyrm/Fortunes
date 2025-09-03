class_name Card
extends RefCounted

var id: int
var suit: DataStructures.SuitType
var value: int
var is_unlocked: bool
var cost: int = 0

func _init(card_id: int = -1, card_suit: DataStructures.SuitType = DataStructures.SuitType.CUPS, card_value: int = 0):
    id = card_id
    suit = card_suit
    value = card_value
    is_unlocked = false

func copy_from(other: Card) -> void:
    id = other.id
    suit = other.suit
    value = other.value
    is_unlocked = other.is_unlocked

func duplicate() -> Card:
    var new_card = Card.new()
    new_card.copy_from(self)
    return new_card

func set_cost(new_cost: int) -> void:
    cost = new_cost