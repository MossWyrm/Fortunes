class_name CupStats

var basic_value: int = GameConfig.DEFAULT_CUP_BASIC_VALUE
var basic_max_quantity: int = GameConfig.DEFAULT_CUP_BASIC_MAX_QUANTITY
var face_max_quantity: int = GameConfig.DEFAULT_CUP_FACE_MAX_QUANTITY
var vessel_quantity: int = GameConfig.DEFAULT_CUP_VESSEL_QUANTITY
var vessel_size: int = GameConfig.DEFAULT_CUP_VESSEL_SIZE
var page_modifier: float = GameConfig.DEFAULT_CUP_PAGE_MODIFIER
var knight_modifier: int = GameConfig.DEFAULT_CUP_KNIGHT_MODIFIER
var queen_modifier: int = GameConfig.DEFAULT_CUP_QUEEN_MODIFIER

func reset():
    basic_value = GameConfig.DEFAULT_CUP_BASIC_VALUE
    basic_max_quantity = GameConfig.DEFAULT_CUP_BASIC_MAX_QUANTITY
    face_max_quantity = GameConfig.DEFAULT_CUP_FACE_MAX_QUANTITY
    vessel_quantity = GameConfig.DEFAULT_CUP_VESSEL_QUANTITY
    vessel_size = GameConfig.DEFAULT_CUP_VESSEL_SIZE
    page_modifier = GameConfig.DEFAULT_CUP_PAGE_MODIFIER
    knight_modifier = GameConfig.DEFAULT_CUP_KNIGHT_MODIFIER
    queen_modifier = GameConfig.DEFAULT_CUP_QUEEN_MODIFIER

func save() -> Dictionary:
    return {
        "basic_value": basic_value,
        "basic_max_quantity": basic_max_quantity,
        "face_max_quantity": face_max_quantity,
        "vessel_quantity": vessel_quantity,
        "vessel_size": vessel_size,
        "page_modifier": page_modifier,
        "knight_modifier": knight_modifier,
        "queen_modifier": queen_modifier
    }

func load(data: Dictionary):
    if data.has("basic_value"):
        basic_value = data["basic_value"]
    if data.has("basic_max_quantity"):
        basic_max_quantity = data["basic_max_quantity"]
    if data.has("face_max_quantity"):
        face_max_quantity = data["face_max_quantity"]
    if data.has("vessel_quantity"):
        vessel_quantity = data["vessel_quantity"]
    if data.has("vessel_size"):
        vessel_size = data["vessel_size"]
    if data.has("page_modifier"):
        page_modifier = data["page_modifier"]
    if data.has("knight_modifier"):
        knight_modifier = data["knight_modifier"]
    if data.has("queen_modifier"):
        queen_modifier = data["queen_modifier"]