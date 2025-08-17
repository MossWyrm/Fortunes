
extends BaseCalculator
class_name WandCalculator

### --- State ---
var wand_stats: WandStats
var wand_multiplier: float = 1.0
var queen_mod: int = 0
var page_charges: int = 0
var page_positive: bool = false
var knight_charges: int = 0
var knight_positive: bool = false

### --- Initialization ---
func set_game_state(state: GameState):
    super.set_game_state(state)
    assert(state and state.stats and state.stats.wand_stats, "WandCalculator requires wand_stats to be present in GameState!")
    wand_stats = state.stats.wand_stats

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    if safely:
        return
    queen_mod = 0
    page_charges = 0
    knight_charges = 0
    wand_multiplier = 1.0

func update(value: float, _flipped: bool = false) -> void:
    wand_multiplier += (float(value)/100.0)
    wand_multiplier = clamp(wand_multiplier, 0.01, 10000)

func bonus() -> float:
    return wand_multiplier

func page_skip() -> bool:
    if page_charges > 0 and not page_positive:
        page_charges -= 1
        return true
    return false

func page_multiply() -> int:
    if not (page_charges > 0 and page_positive):
        return 1
    var charges: int = page_charges
    page_charges = 0
    return charges

# --- Knight effect for post-calc ---
func wand_knight_check() -> bool:
    return knight_charges > 0

func wand_knight_multi() -> float:
    if knight_charges > 0:
        knight_charges -= 1
        return bonus() if knight_positive else 1.0 / bonus()
    return 1.0

### --- Calculation Methods ---
# Override for Wand-specific value modification logic
func _value_modifier(value: int, flipped: bool = false) -> int:
    var updated_value = -value if flipped else value
    update(updated_value, flipped)
    updated_value = roundi(float(updated_value) * bonus())
    return updated_value

func calculate_base_value(card: Card, _flipped: bool) -> int:
    return card.value + wand_stats.basic_value + queen_mod

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    if page_skip():
        return 0
    var total: int = 0
    var mult: int = page_multiply()
    for _i in range(mult):
        total += _route_card_calculation(card, base_value, flipped)
    return total

func _basic(value: int, flipped: bool) -> int:
    var val = _value_modifier(value, flipped)
    return val

func _page(value: int, flipped: bool) -> int:
    page_positive = !flipped
    page_charges = wand_stats.page_modifier
    if page_skip():
        return 0
    var total: int = 0
    var mult = page_multiply()
    for _i in range(mult):
        total += _value_modifier(value, flipped)
    return total

func _knight(value: int, flipped: bool) -> int:
    knight_positive = !flipped
    knight_charges = wand_stats.knight_modifier
    var val = _value_modifier(value, flipped)
    return val

func _queen(value: int, flipped: bool) -> int:
    queen_mod = (wand_stats.queen_modifier if !flipped else -wand_stats.queen_modifier)
    var val = _value_modifier(value, flipped)
    return val

func _king(value: int, flipped: bool) -> int:
    if !flipped:
        wand_multiplier = pow(wand_multiplier, 2)
    else:
        wand_multiplier = sqrt(wand_multiplier)
    var val = _value_modifier(value, flipped)
    return val

### --- State Backup/Restore ---
func get_display_state() -> Dictionary:
    return {
        "value": wand_multiplier,
        "value_buff": queen_mod,
        "page_charges": page_charges,
        "knight_charges": knight_charges,
        "page_positive": page_positive,
        "knight_positive": knight_positive,
    }


func get_state_backup() -> Dictionary:
    return {
        "wand_multiplier": wand_multiplier,
        "queen_mod": queen_mod,
        "page_charges": page_charges,
        "page_positive": page_positive,
        "knight_charges": knight_charges,
        "knight_positive": knight_positive
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("wand_multiplier"):
        wand_multiplier = backup["wand_multiplier"]
    if backup.has("queen_mod"):
        queen_mod = backup["queen_mod"]
    if backup.has("page_charges"):
        page_charges = backup["page_charges"]
    if backup.has("page_positive"):
        page_positive = backup["page_positive"]
    if backup.has("knight_charges"):
        knight_charges = backup["knight_charges"]
    if backup.has("knight_positive"):
        knight_positive = backup["knight_positive"]