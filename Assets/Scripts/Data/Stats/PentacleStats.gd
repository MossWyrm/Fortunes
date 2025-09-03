class_name PentacleStats

var basic_value: int = GameConfig.DEFAULT_PENTACLE_BASIC_VALUE
var basic_max_quantity: int = GameConfig.DEFAULT_PENTACLE_BASIC_MAX_QUANTITY
var face_max_quantity: int = GameConfig.DEFAULT_PENTACLE_FACE_MAX_QUANTITY
var page_modifier: float = GameConfig.DEFAULT_PENTACLE_PAGE_MODIFIER
var knight_uses: int = GameConfig.DEFAULT_PENTACLE_KNIGHT_USES
var queen_uses: int = GameConfig.DEFAULT_PENTACLE_QUEEN_USES
var king_uses: int = GameConfig.DEFAULT_PENTACLE_KING_USES
var king_value: int = GameConfig.DEFAULT_PENTACLE_KING_VALUE

func reset():
    basic_value = GameConfig.DEFAULT_PENTACLE_BASIC_VALUE
    basic_max_quantity = GameConfig.DEFAULT_PENTACLE_BASIC_MAX_QUANTITY
    face_max_quantity = GameConfig.DEFAULT_PENTACLE_FACE_MAX_QUANTITY
    page_modifier = GameConfig.DEFAULT_PENTACLE_PAGE_MODIFIER
    knight_uses = GameConfig.DEFAULT_PENTACLE_KNIGHT_USES
    queen_uses = GameConfig.DEFAULT_PENTACLE_QUEEN_USES
    king_uses = GameConfig.DEFAULT_PENTACLE_KING_USES
    king_value = GameConfig.DEFAULT_PENTACLE_KING_VALUE

func save() -> Dictionary:
    return {
        "basic_value": basic_value,
        "basic_max_quantity": basic_max_quantity,
        "face_max_quantity": face_max_quantity,
        "page_modifier": page_modifier,
        "knight_uses": knight_uses,
        "queen_uses": queen_uses,
        "king_uses": king_uses,
        "king_value": king_value
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
    if data.has("knight_uses"):
        knight_uses = data["knight_uses"]
    if data.has("queen_uses"):
        queen_uses = data["queen_uses"]
    if data.has("king_uses"):
        king_uses = data["king_uses"]
    if data.has("king_value"):
        king_value = data["king_value"]