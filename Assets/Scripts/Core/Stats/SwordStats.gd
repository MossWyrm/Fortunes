class_name SwordStats

var basic_value: int = 0
var basic_max_quantity: int = 1
var face_max_quantity: int = 1
var knight_modifier: int = 5
var knight_super: bool = false
var queen_modifier: int = 1
var king_modifier: int = 3

func reset():
    basic_value = 0
    basic_max_quantity = 1
    face_max_quantity = 1
    knight_modifier = 5
    knight_super = false
    queen_modifier = 1
    king_modifier = 3

func save() -> Dictionary:
    return {
        "basic_value": basic_value,
        "basic_max_quantity": basic_max_quantity,
        "face_max_quantity": face_max_quantity,
        "knight_modifier": knight_modifier,
        "knight_super": knight_super,
        "queen_modifier": queen_modifier,
        "king_modifier": king_modifier
    }

func load(data: Dictionary):
    if data.has("basic_value"):
        basic_value = data["basic_value"]
    if data.has("basic_max_quantity"):
        basic_max_quantity = data["basic_max_quantity"]
    if data.has("face_max_quantity"):
        face_max_quantity = data["face_max_quantity"]
    if data.has("knight_modifier"):
        knight_modifier = data["knight_modifier"]
    if data.has("knight_super"):
        knight_super = data["knight_super"]
    if data.has("queen_modifier"):
        queen_modifier = data["queen_modifier"]
    if data.has("king_modifier"):
        king_modifier = data["king_modifier"]