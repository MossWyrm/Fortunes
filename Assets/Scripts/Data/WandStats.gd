class_name WandStats

var basic_value: int = GameConfig.DEFAULT_WAND_BASIC_VALUE
var basic_max_quantity: int = GameConfig.DEFAULT_WAND_BASIC_MAX_QUANTITY
var face_max_quantity: int = GameConfig.DEFAULT_WAND_FACE_MAX_QUANTITY
var page_modifier: int = GameConfig.DEFAULT_WAND_PAGE_MODIFIER
var knight_modifier: int = GameConfig.DEFAULT_WAND_KNIGHT_MODIFIER
var queen_modifier: int = GameConfig.DEFAULT_WAND_QUEEN_MODIFIER
var king_modifier: int = GameConfig.DEFAULT_WAND_KING_MODIFIER

func reset():
    basic_value = GameConfig.DEFAULT_WAND_BASIC_VALUE
    basic_max_quantity = GameConfig.DEFAULT_WAND_BASIC_MAX_QUANTITY
    face_max_quantity = GameConfig.DEFAULT_WAND_FACE_MAX_QUANTITY
    page_modifier = GameConfig.DEFAULT_WAND_PAGE_MODIFIER
    knight_modifier = GameConfig.DEFAULT_WAND_KNIGHT_MODIFIER
    queen_modifier = GameConfig.DEFAULT_WAND_QUEEN_MODIFIER
    king_modifier = GameConfig.DEFAULT_WAND_KING_MODIFIER

func save() -> Dictionary:
    return {
        "basic_value": basic_value,
        "basic_max_quantity": basic_max_quantity,
        "face_max_quantity": face_max_quantity,
        "page_modifier": page_modifier,
        "knight_modifier": knight_modifier,
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
    if data.has("page_modifier"):
        page_modifier = data["page_modifier"]
    if data.has("knight_modifier"):
        knight_modifier = data["knight_modifier"]
    if data.has("queen_modifier"):
        queen_modifier = data["queen_modifier"]
    if data.has("king_modifier"):
        king_modifier = data["king_modifier"]