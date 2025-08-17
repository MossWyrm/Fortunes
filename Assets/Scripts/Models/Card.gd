class_name Card
extends RefCounted

var id: int
var suit: DataStructures.SuitType
var value: int
var is_unlocked: bool
var is_flipped: bool

func _init(card_id: int, card_suit: DataStructures.SuitType, card_value: int):
    id = card_id
    suit = card_suit
    value = card_value
    is_unlocked = false
    is_flipped = false

func copy_from(other: Card) -> void:
    id = other.id
    suit = other.suit
    value = other.value
    is_unlocked = other.is_unlocked
    is_flipped = other.is_flipped