extends Resource
class_name Card

enum Suits {cups = 0, wands = 1, pentacles = 2, swords = 3, major = 4} 

@export var card_suit: Suits
@export var card_title: String
@export var card_default_value: int
@export_range(100,1000) var card_id_num: int
@export var card_image: Texture2D
@export var unlocked: bool = true
@export var unlock_cost: int = 0

func _get_title():
    return card_title