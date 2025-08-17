class_name SuitState
extends RefCounted

# Represents the state of a suit in the game
var suit: DataStructures.SuitType
var is_active: bool
var charges: int
var value: float
var modifiers: Dictionary

func _init(suit_type: DataStructures.SuitType):
    suit = suit_type
    is_active = false
    charges = 0
    value = 0.0
    modifiers = {}