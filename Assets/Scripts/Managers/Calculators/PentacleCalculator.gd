
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
    DebugManager.print_card_effects("PentacleCalculator: Game state set - queen_uses: %d, knight_uses: %d, king_uses: %d, king_value: %d" % [pentacle_stats.queen_uses, pentacle_stats.knight_uses, pentacle_stats.king_uses, pentacle_stats.king_value], DebugManager.DebugLevel.INFO)

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    DebugManager.print_card_effects("PentacleCalculator: Shuffle called - safely: %s, current state: pentacles=%d, charges=%d, queen_charges=%d, blocked=%s" % [str(safely), current_pentacles, charges, queen_charges, str(blocked)], DebugManager.DebugLevel.INFO)
    blocked = false
    if safely:
        return
    _reset(true)
    DebugManager.print_card_effects("PentacleCalculator: Shuffle completed - all values reset", DebugManager.DebugLevel.INFO)

func update(value: int, override: bool = false) -> void:
    if blocked:
        DebugManager.print_card_effects("PentacleCalculator: Update blocked - cannot modify pentacles", DebugManager.DebugLevel.WARNING)
        return
    var old_value = current_pentacles
    current_pentacles = value if override else current_pentacles + value
    current_pentacles = max(current_pentacles, 0)
    DebugManager.print_card_effects("PentacleCalculator: Updated pentacles from %d to %d (value: %d, override: %s)" % [old_value, current_pentacles, value, str(override)], DebugManager.DebugLevel.VERBOSE)

func adjust_charges(value: int, override: bool = false) -> void:
    var old_charges = charges
    charges = value if override else charges + value
    DebugManager.print_card_effects("PentacleCalculator: Charges adjusted from %d to %d (value: %d, override: %s)" % [old_charges, charges, value, str(override)], DebugManager.DebugLevel.VERBOSE)
    if charges <= 0:
        DebugManager.print_card_effects("PentacleCalculator: Charges depleted - resetting pentacles", DebugManager.DebugLevel.INFO)
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
        DebugManager.print_card_effects("PentacleCalculator: Cannot use pentacles - value: %d, charges: %d, pentacles: %d" % [value, charges, current_pentacles], DebugManager.DebugLevel.VERBOSE)
        return value
    var abs_value : int = abs(value)
    var used : int = min(current_pentacles, abs_value)
    if charges <= 0:
        current_pentacles -= used
    charges = max(charges-1,0)
    var output_value : int = value + used
    current_pentacles = max(current_pentacles, 0)
    DebugManager.print_card_effects("PentacleCalculator: Used %d pentacles to mitigate negative value from %d to %d (charges: %d -> %d)" % [used, value, output_value, charges + 1, charges], DebugManager.DebugLevel.INFO)
    return output_value

func _reset(queenincluded: bool) -> void:
    current_pentacles = 0
    charges = 0
    if queenincluded:
        queen_inverted = false
        queen_charges = 0

### --- Calculation Methods ---
func calculate_base_value(card: Card, _flipped: bool) -> int:
    # Apply integer bonuses first
    var base_result = card.value + pentacle_stats.basic_value

    # Then apply multiplicative bonus
    var result = base_result * pentacle_stats.basic_value_multiplier

    # Apply synergy multipliers if available
    if game_state and game_state.stats:
        result *= game_state.stats.pentacles_protection_bonus
        result *= game_state.stats.arcana_synergy_multiplier

    var final_result = int(result)
    DebugManager.print_card_effects("PentacleCalculator: Base value calculated - card: %d + basic: %d = %d, multiplier: %.3f, pentacles_bonus: %.3f, arcana_synergy: %.3f, final: %d" % [card.value, pentacle_stats.basic_value, base_result, pentacle_stats.basic_value_multiplier, game_state.stats.pentacles_protection_bonus if game_state and game_state.stats else 1.0, game_state.stats.arcana_synergy_multiplier if game_state and game_state.stats else 1.0, final_result], DebugManager.DebugLevel.VERBOSE)
    return final_result

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    var pre_pentacles = current_pentacles
    var pre_charges = charges
    var result = _route_card_calculation(card, base_value, flipped)
    DebugManager.print_card_effects("PentacleCalculator: Main calculation completed - card: %s (flipped: %s), result: %d, pentacles: %d->%d, charges: %d->%d" % [Tools.get_card_title(card), str(flipped), result, pre_pentacles, current_pentacles, pre_charges, charges], DebugManager.DebugLevel.INFO)
    return result

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
    var base_val = _value_modifier(base_value, flipped)
    var final_val = int(base_val * pentacle_stats.knight_multiplier)
    DebugManager.print_card_effects("PentacleCalculator: Knight multiplier applied - base: %d * %.3f = %d" % [base_val, pentacle_stats.knight_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    update(final_val)
    adjust_charges(pentacle_stats.knight_uses * ( -1 if flipped else 1))
    return current_pentacles + final_val

func _queen(base_value: int, flipped: bool) -> int:
    update_queen_pentacles(flipped)
    var base_val = _value_modifier(base_value, flipped)
    var final_val = int(base_val * pentacle_stats.queen_multiplier)
    DebugManager.print_card_effects("PentacleCalculator: Queen multiplier applied - base: %d * %.3f = %d" % [base_val, pentacle_stats.queen_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    update(final_val)
    return current_pentacles + final_val

func _king(base_value: int, flipped: bool) -> int:
    var base_val = _value_modifier(base_value, flipped)
    var final_val = int(base_val * pentacle_stats.king_multiplier)
    DebugManager.print_card_effects("PentacleCalculator: King multiplier applied - base: %d * %.3f = %d" % [base_val, pentacle_stats.king_multiplier, final_val], DebugManager.DebugLevel.VERBOSE)
    if flipped:
        DebugManager.print_card_effects("PentacleCalculator: King (flipped) - blocking pentacles and resetting charges/value", DebugManager.DebugLevel.INFO)
        adjust_charges(0)
        update(0, true)
        blocked = true
    else:
        DebugManager.print_card_effects("PentacleCalculator: King (upright) - adding %d charges and %d pentacles" % [pentacle_stats.king_uses, pentacle_stats.king_value], DebugManager.DebugLevel.INFO)
        adjust_charges(pentacle_stats.king_uses)
        update(pentacle_stats.king_value, false)
    return current_pentacles + final_val

### --- Utility ---
func get_display_state() -> Dictionary:
    var dict = {
        "value": current_pentacles,
        "uses": charges,
        "queen_uses": queen_charges,
        "queen_inverted": queen_inverted,
        "blocked": blocked,
    }
    return dict


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

### --- Death Reset ---
func death_reset(clear_positive: bool) -> int:
    var effects_cleared: int = 0
    
    if clear_positive:
        # Clear positive pentacle effects
        if current_pentacles > 0:
            current_pentacles = 0
            effects_cleared += 1
        if charges > 0:
            charges = 0
            effects_cleared += 1
        if queen_charges > 0:
            queen_charges = 0
            effects_cleared += 1
    else:
        # Clear negative pentacle effects
        if blocked:
            blocked = false
            effects_cleared += 1
        if queen_inverted:
            queen_inverted = false
            effects_cleared += 1
    
    return effects_cleared