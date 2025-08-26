# Base calculator class
class_name BaseCalculator

var game_state: GameState

func set_game_state(state: GameState):
    game_state = state

func calculate_base_value(_card: Card, _flipped: bool) -> int:
    return 0

func calculate_main_value(_card: Card, base_value: int, _flipped: bool) -> int:
    return base_value

func get_state_backup() -> Dictionary:
    return {}

func restore_state_backup(_backup: Dictionary):
    pass

func shuffle(_safely: bool) -> void:
    pass

### --- Common Calculator Patterns ---

# Standard value modifier for flipped cards
func _value_modifier(value: int, flipped: bool = false) -> int:
    return -value if flipped else value

# Standard card type routing based on card value
func _route_card_calculation(card: Card, base_value: int, flipped: bool) -> int:
    match card.value:
        GameConstants.CARD_RANK_PAGE:	return _page(base_value, flipped)
        GameConstants.CARD_RANK_KNIGHT:	return _knight(base_value, flipped)
        GameConstants.CARD_RANK_QUEEN:	return _queen(base_value, flipped)
        GameConstants.CARD_RANK_KING:	return _king(base_value, flipped)
        _:	return _basic(base_value, flipped)

# Override these in derived classes for suit-specific behavior
func _basic(_base_value: int, _flipped: bool) -> int:
    return 0

func _page(_base_value: int, _flipped: bool) -> int:
    return 0

func _knight(_base_value: int, _flipped: bool) -> int:
    return 0

func _queen(_base_value: int, _flipped: bool) -> int:
    return 0

func _king(_base_value: int, _flipped: bool) -> int:
    return 0