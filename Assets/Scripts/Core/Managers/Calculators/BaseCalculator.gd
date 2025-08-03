# Base calculator class
class_name BaseCalculator

var game_state: GameState
var event_bus: EventBus

func set_game_state(state: GameState):
    game_state = state
    event_bus = state.event_bus

func calculate_base_value(_card: DataStructures.Card, _flipped: bool) -> int:
    return 0

func calculate_main_value(_card: DataStructures.Card, base_value: int, _flipped: bool) -> int:
    return base_value

func get_state_backup() -> Dictionary:
    return {}

func restore_state_backup(_backup: Dictionary):
    pass