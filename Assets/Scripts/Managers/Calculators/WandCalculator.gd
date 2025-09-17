
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
var prevent_knight_for_this_draw: bool = false

### --- Initialization ---
func set_game_state(state: GameState):
    super.set_game_state(state)
    assert(state and state.stats and state.stats.wand_stats, "WandCalculator requires wand_stats to be present in GameState!")
    wand_stats = state.stats.wand_stats
    DebugManager.print_card_effects("WandCalculator: Game state set - page_mod: %d, queen_mod: %d, knight_mod: %d" % [wand_stats.page_modifier, wand_stats.queen_modifier, wand_stats.knight_modifier], DebugManager.DebugLevel.INFO)

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    DebugManager.print_card_effects("WandCalculator: Shuffle called - safely: %s, current state: multiplier=%.2f, queen_mod=%d, page_charges=%d, knight_charges=%d" % [str(safely), wand_multiplier, queen_mod, page_charges, knight_charges], DebugManager.DebugLevel.INFO)
    if safely:
        return
    queen_mod = 0
    page_charges = 0
    knight_charges = 0
    wand_multiplier = 1.0
    DebugManager.print_card_effects("WandCalculator: Shuffle completed - all values reset to defaults", DebugManager.DebugLevel.INFO)

func update(value: float, _flipped: bool = false) -> void:
    var old_multiplier = wand_multiplier
    wand_multiplier += (float(value)/100.0)
    wand_multiplier = clamp(wand_multiplier, 0.01, 10000)
    DebugManager.print_card_effects("WandCalculator: Multiplier updated from %.3f to %.3f (value: %.2f)" % [old_multiplier, wand_multiplier, value], DebugManager.DebugLevel.VERBOSE)

func bonus() -> float:
    return wand_multiplier

func page_skip() -> bool:
    if page_charges > 0 and not page_positive:
        page_charges -= 1
        DebugManager.print_card_effects("WandCalculator: Page skip applied - charges: %d remaining" % page_charges, DebugManager.DebugLevel.INFO)
        return true
    return false

func page_multiply() -> int:
    if not (page_charges > 0 and page_positive):
        return 1
    var charges: int = page_charges
    page_charges = 0
    DebugManager.print_card_effects("WandCalculator: Page multiply applied - multiplying calculation %d times" % charges, DebugManager.DebugLevel.INFO)
    return charges

# --- Knight effect for post-calc ---
func wand_knight_check() -> bool:
    return knight_charges > 0

func wand_knight_multi() -> float:
    if knight_charges > 0 and not prevent_knight_for_this_draw:
        knight_charges -= 1
        var multiplier = bonus() if knight_positive else 1.0 / bonus()
        DebugManager.print_card_effects("WandCalculator: Knight multiplier applied - %.3f (positive: %s, charges left: %d)" % [multiplier, str(knight_positive), knight_charges], DebugManager.DebugLevel.INFO)
        return multiplier
    prevent_knight_for_this_draw = false
    return 1.0

### --- Calculation Methods ---
# Override for Wand-specific value modification logic
func _value_modifier(value: int, flipped: bool = false) -> int:
    var updated_value = -value if flipped else value
    update(updated_value, flipped)
    updated_value = roundi(float(updated_value) * bonus())
    return updated_value

func calculate_base_value(card: Card, _flipped: bool) -> int:
    # Apply integer bonuses first
    var base_result = card.value + wand_stats.basic_value + queen_mod

    # Then apply multiplicative bonus
    var result = base_result * wand_stats.basic_value_multiplier

    # Apply synergy multipliers if available
    if game_state and game_state.stats:
        result *= game_state.stats.wands_multiplier_bonus
        result *= game_state.stats.arcana_synergy_multiplier

    var final_result = int(result)
    DebugManager.print_card_effects("WandCalculator: Base value calculated - card: %d + basic: %d + queen_mod: %d = %d, multiplier: %.3f, wands_bonus: %.3f, arcana_synergy: %.3f, final: %d" % [card.value, wand_stats.basic_value, queen_mod, base_result, wand_stats.basic_value_multiplier, game_state.stats.wands_multiplier_bonus if game_state and game_state.stats else 1.0, game_state.stats.arcana_synergy_multiplier if game_state and game_state.stats else 1.0, final_result], DebugManager.DebugLevel.VERBOSE)
    return final_result

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    if page_skip():
        DebugManager.print_card_effects("WandCalculator: Card skipped due to page effect", DebugManager.DebugLevel.INFO)
        return 0
    var old_multiplier = wand_multiplier
    var total: int = 0
    var mult: int = page_multiply()
    for _i in range(mult):
        total += _route_card_calculation(card, base_value, flipped)
    DebugManager.print_card_effects("WandCalculator: Main calculation completed - card: %s (flipped: %s), multiplier: %.3f->%.3f, page_mult: %d, result: %d" % [Tools.get_card_title(card), str(flipped), old_multiplier, wand_multiplier, mult, total], DebugManager.DebugLevel.INFO)
    return total

func _basic(value: int, flipped: bool) -> int:
    var val = _value_modifier(value, flipped)
    return val

func _page(value: int, flipped: bool) -> int:
    if page_skip():
        return 0
    var total: int = 0
    var mult = page_multiply()
    for _i in range(mult):
        total += _value_modifier(value, flipped)
    page_positive = !flipped
    page_charges = wand_stats.page_modifier
    DebugManager.print_card_effects("WandCalculator: Page card - set %d charges (positive: %s)" % [page_charges, str(page_positive)], DebugManager.DebugLevel.INFO)
    return total

func _knight(value: int, flipped: bool) -> int:
    knight_positive = !flipped
    knight_charges = wand_stats.knight_modifier
    prevent_knight_for_this_draw = true
    DebugManager.print_card_effects("WandCalculator: Knight card - set %d charges (positive: %s)" % [knight_charges, str(knight_positive)], DebugManager.DebugLevel.INFO)
    var base_val = _value_modifier(value, flipped)
    var final_val = int(base_val * wand_stats.knight_multiplier)
    DebugManager.print_card_effects("WandCalculator: Knight multiplier applied - base: %d * %.3f = %d" % [base_val, wand_stats.knight_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    return final_val

func _queen(value: int, flipped: bool) -> int:
    var old_mod = queen_mod
    queen_mod = (wand_stats.queen_modifier if !flipped else -wand_stats.queen_modifier)
    DebugManager.print_card_effects("WandCalculator: Queen card - queen modifier changed from %d to %d (flipped: %s)" % [old_mod, queen_mod, str(flipped)], DebugManager.DebugLevel.INFO)
    var base_val = _value_modifier(value, flipped)
    var final_val = int(base_val * wand_stats.queen_multiplier)
    DebugManager.print_card_effects("WandCalculator: Queen multiplier applied - base: %d * %.3f = %d" % [base_val, wand_stats.queen_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    return final_val

func _king(value: int, flipped: bool) -> int:
    var old_multiplier = wand_multiplier
    if !flipped:
        wand_multiplier = pow(wand_multiplier, wand_stats.king_modifier)
        DebugManager.print_card_effects("WandCalculator: King (upright) - multiplier raised to power of %d from %.3f to %.3f" % [wand_stats.king_modifier, old_multiplier, wand_multiplier], DebugManager.DebugLevel.INFO)
    else:
        wand_multiplier = pow(wand_multiplier, 1.0 / float(wand_stats.king_modifier))
        DebugManager.print_card_effects("WandCalculator: King (flipped) - multiplier raised to power of %s from %.3f to %.3f" % [str("1/"+str(wand_stats.king_modifier)), old_multiplier, wand_multiplier], DebugManager.DebugLevel.INFO)
    var base_val = _value_modifier(value, flipped)
    var final_val = int(base_val * wand_stats.king_multiplier)
    DebugManager.print_card_effects("WandCalculator: King multiplier applied - base: %d * %.3f = %d" % [base_val, wand_stats.king_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    return final_val

### --- State Backup/Restore ---
func get_display_state() -> Dictionary:
    var dict = {
        "value": wand_multiplier,
        "value_buff": queen_mod,
        "page_charges": page_charges,
        "knight_charges": knight_charges,
        "page_positive": page_positive,
        "knight_positive": knight_positive,
    }
    return dict


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

### --- Death Reset ---
func death_reset(clear_positive: bool) -> int:
    var effects_cleared: int = 0
    
    if clear_positive:
        # Clear positive wand effects
        if wand_multiplier > 1.0:
            wand_multiplier = 1.0
            effects_cleared += 1
        if queen_mod > 0:
            queen_mod = 0
            effects_cleared += 1
        if page_charges > 0 and page_positive:
            page_charges = 0
            effects_cleared += 1
        if knight_charges > 0 and knight_positive:
            knight_charges = 0
            effects_cleared += 1
    else:
        # Clear negative wand effects
        if wand_multiplier < 1.0:
            wand_multiplier = 1.0
            effects_cleared += 1
        if queen_mod < 0:
            queen_mod = 0
            effects_cleared += 1
        if page_charges > 0 and not page_positive:
            page_charges = 0
            effects_cleared += 1
        if knight_charges > 0 and not knight_positive:
            knight_charges = 0
            effects_cleared += 1
    
    return effects_cleared