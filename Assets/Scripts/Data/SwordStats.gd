class_name SwordStats

var basic_value: int = GameConfig.DEFAULT_SWORD_BASIC_VALUE
var basic_max_quantity: int = GameConfig.DEFAULT_SWORD_BASIC_MAX_QUANTITY
var face_max_quantity: int = GameConfig.DEFAULT_SWORD_FACE_MAX_QUANTITY
var knight_modifier: int = GameConfig.DEFAULT_SWORD_KNIGHT_MODIFIER
var knight_super: bool = GameConfig.DEFAULT_SWORD_KNIGHT_SUPER
var queen_modifier: int = GameConfig.DEFAULT_SWORD_QUEEN_MODIFIER
var king_modifier: int = GameConfig.DEFAULT_SWORD_KING_MODIFIER

func reset():
    basic_value = GameConfig.DEFAULT_SWORD_BASIC_VALUE
    basic_max_quantity = GameConfig.DEFAULT_SWORD_BASIC_MAX_QUANTITY
    face_max_quantity = GameConfig.DEFAULT_SWORD_FACE_MAX_QUANTITY
    knight_modifier = GameConfig.DEFAULT_SWORD_KNIGHT_MODIFIER
    knight_super = GameConfig.DEFAULT_SWORD_KNIGHT_SUPER
    queen_modifier = GameConfig.DEFAULT_SWORD_QUEEN_MODIFIER
    king_modifier = GameConfig.DEFAULT_SWORD_KING_MODIFIER

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