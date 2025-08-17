
extends BaseCalculator
class_name PentacleCalculator

### --- State ---
var pentacle_stats: PentacleStats
var current_pentacles: int = 0
var charges: int = 0
var queen_charges: int = 0
var queen_inverted: bool = false
var blocked: bool = false

### --- Initialization ---
func set_game_state(state: GameState):
    super.set_game_state(state)
    assert(state and state.stats and state.stats.pentacle_stats, "PentacleCalculator requires pentacle_stats to be present in GameState!")
    pentacle_stats = state.stats.pentacle_stats

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    blocked = false
    if safely:
        return
    _reset(true)

func update(value: int, override: bool = false) -> void:
    if blocked:
        return
    current_pentacles = value if override else current_pentacles + value
    current_pentacles = max(current_pentacles, 0)

func adjust_charges(value: int, override: bool = false) -> void:
    charges = value if override else charges + value
    if charges <= 0:
        _reset(false)

func draw_page(flipped: bool) -> void:
    var mod = (1 - pentacle_stats.page_modifier) if flipped else (1 + pentacle_stats.page_modifier)
    current_pentacles = roundi(current_pentacles * mod)

func update_queen_pentacles(flipped: bool) -> void:
    queen_inverted = flipped
    queen_charges += pentacle_stats.queen_uses

func use_queen_pentacles(flipped: bool) -> bool:
    if queen_charges > 0 and flipped != queen_inverted:
        queen_charges -= 1
        return true
    return false

func use_pentacles(value: int) -> int:
    if value >= 0 or charges <= 0 or current_pentacles <= 0:
        return value
    var abs_value : int = abs(value)
    var used : int = min(current_pentacles, abs_value)
    current_pentacles -= used
    charges -= 1
    var output_value : int = value + used
    current_pentacles = max(current_pentacles, 0)
    charges = max(charges, 0)
    return output_value

func _reset(queenincluded: bool) -> void:
    current_pentacles = 0
    charges = 0
    if queenincluded:
        queen_inverted = false
        queen_charges = 0

### --- Calculation Methods ---
func calculate_base_value(card: Card, _flipped: bool) -> int:
    return card.value + pentacle_stats.basic_value

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    return _route_card_calculation(card, base_value, flipped)

func _basic(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    update(val)
    return current_pentacles + val

func _page(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    update(val)
    draw_page(flipped)
    return current_pentacles + val

func _knight(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    update(val)
    adjust_charges(pentacle_stats.knight_uses * ( -1 if flipped else 1))
    return current_pentacles + val

func _queen(base_value: int, flipped: bool) -> int:
    update_queen_pentacles(flipped)
    var val = _value_modifier(base_value, flipped)
    update(val)
    return current_pentacles + val

func _king(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    if flipped:
        adjust_charges(0)
        update(0, true)
        blocked = true
    else:
        adjust_charges(pentacle_stats.king_uses)
        update(pentacle_stats.king_value, false)
    return current_pentacles + val

### --- Utility ---
func get_display_state() -> Dictionary:
    return {
        "value": current_pentacles,
        "uses": charges,
        "queen_uses": queen_charges,
        "queen_inverted": queen_inverted,
        "blocked": blocked,
    }

func get_state_backup() -> Dictionary:
    return get_display_state()

func restore_state(state: Dictionary) -> void:
    if state.has("value"):
        current_pentacles = state["value"]
    if state.has("uses"):
        charges = state["uses"]
    if state.has("queen_uses"):
        queen_charges = state["queen_uses"]
    if state.has("queen_inverted"):
        queen_inverted = state["queen_inverted"]
    if state.has("blocked"):
        blocked = state["blocked"]

func restore_state_backup(backup: Dictionary):
    restore_state(backup)

func check_queen_pent(flipped: bool) -> bool:
    return use_queen_pentacles(flipped)