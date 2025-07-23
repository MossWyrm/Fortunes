extends Node
class_name Card

@export var card_suit: ID.Suits
@export var card_title: String
@export var card_default_value: int
@export_range(100,1000) var card_id_num: int
@export var unlocked: bool = true
@export var unlock_cost: int = 0
@export var blocked: bool = false

func get_title() -> String:
    return card_title