class_name PentacleStats

var basic_value: int = 0
var basic_max_quantity: int = 1
var face_max_quantity: int = 1
var page_modifier: float = 0.1
var knight_uses: int = 1
var queen_uses: int = 1
var king_uses: int = 3
var king_value: int = 100

func reset():
    basic_value = 0
    basic_max_quantity = 1
    face_max_quantity = 1
    page_modifier = 0.1
    knight_uses = 1
    queen_uses = 1
    king_uses = 3
    king_value = 100

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