class_name CupStats

var basic_value: int = 0
var basic_max_quantity: int = 1f
var face_max_quantity: int = 1
var vessel_quantity: int = 1
var vessel_size: int = 100
var page_modifier: float = 0.2
var knight_modifier: int = 1
var queen_modifier: int = 1

func reset():
    basic_value = 0
    basic_max_quantity = 1
    face_max_quantity = 1
    vessel_quantity = 1
    vessel_size = 100
    page_modifier = 0.2
    knight_modifier = 1
    queen_modifier = 1

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