
extends BaseCalculator
class_name SwordCalculator


### --- State ---
var sword_stats: SwordStats
var combo: float = 1.0
var combo_dir_flipped: bool = false
var combo_value: float = 1.0
var page_pos_charges: int = 0
var page_neg_charges: int = 0
var king_protection: int = 0
var king_destruction: int = 0


### --- Initialization ---
func set_game_state(state: GameState):
    super.set_game_state(state)
    assert(state and state.stats and state.stats.sword_stats, "SwordCalculator requires sword_stats to be present in GameState!")
    sword_stats = state.stats.sword_stats
    DebugManager.print_card_effects("SwordCalculator: Game state set - page_mod: %d, queen_mod: %d, king_mod: %d, knight_mod: %d" % [sword_stats.page_modifier, sword_stats.queen_modifier, sword_stats.king_modifier, sword_stats.knight_modifier], DebugManager.DebugLevel.INFO)

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    DebugManager.print_card_effects("SwordCalculator: Shuffle called - safely: %s, current combo: %d, charges: pos=%d/neg=%d, king: prot=%d/dest=%d" % [str(safely), combo, page_pos_charges, page_neg_charges, king_protection, king_destruction], DebugManager.DebugLevel.INFO)
    if safely:
        return
    combo = 1
    combo_dir_flipped = false
    combo_value = 1
    page_pos_charges = 0
    page_neg_charges = 0
    king_protection = 0
    king_destruction = 0
    DebugManager.print_card_effects("SwordCalculator: Shuffle completed - all values reset to defaults", DebugManager.DebugLevel.INFO)
    
# Update combo and king state for a new card direction
func update_combo(flipped: bool) -> void:
    var old_combo = combo
    var old_dir = combo_dir_flipped
    if combo_dir_flipped == flipped:
        if king_destruction > 0:
            DebugManager.print_card_effects("SwordCalculator: Same direction, but king destruction protected combo (charges: %d -> %d)" % [king_destruction, king_destruction - 1], DebugManager.DebugLevel.VERBOSE)
            king_destruction -= 1
        else:
            combo += combo_value
            DebugManager.print_card_effects("SwordCalculator: Same direction - combo increased by %d (from %d to %d)" % [combo_value, old_combo, combo], DebugManager.DebugLevel.VERBOSE)
    else:
        if king_protection > 0:
            DebugManager.print_card_effects("SwordCalculator: Direction change, but king protection saved combo (charges: %d -> %d)" % [king_protection, king_protection - 1], DebugManager.DebugLevel.VERBOSE)
            king_protection -= 1
        else:
            DebugManager.print_card_effects("SwordCalculator: Direction change - combo reset from %d to 1, direction: %s -> %s" % [old_combo, str(old_dir), str(flipped)], DebugManager.DebugLevel.INFO)
            combo = 1
            combo_dir_flipped = flipped

# Get current combo multiplier
func get_combo() -> int:
    return combo

# Handle drawing a Page card
func add_page_charge(flipped: bool) -> void:
    if flipped:
        page_neg_charges += sword_stats.page_modifier
        DebugManager.print_card_effects("SwordCalculator: Page (flipped) - added %d negative charges (total: %d)" % [sword_stats.page_modifier, page_neg_charges], DebugManager.DebugLevel.VERBOSE)
    else:
        page_pos_charges += sword_stats.page_modifier
        DebugManager.print_card_effects("SwordCalculator: Page (upright) - added %d positive charges (total: %d)" % [sword_stats.page_modifier, page_pos_charges], DebugManager.DebugLevel.VERBOSE)

# Handle drawing a Queen card
func adjust_combo_value_for_queen(flipped: bool) -> void:
    var old_value = combo_value
    var modifier = sword_stats.queen_modifier
    if not flipped:
        combo_value += modifier
    else:
        if combo_value - modifier > 0:
            combo_value -= modifier
        else:
            # If subtracting would reach zero or below, start using decimals
            # Each further queen_modifier subtracts 0.1 per point from 1.0
            var decimal_decrease = float(modifier) * 0.1
            combo_value = max(0.1, combo_value - decimal_decrease)
    if combo_value < 0.1:
        combo_value = 0.1
    DebugManager.print_card_effects("SwordCalculator: Queen (flipped: %s) - combo value changed from %s to %s (modifier: %d)" % [str(flipped), str(old_value), str(combo_value), modifier], DebugManager.DebugLevel.INFO)

# Handle drawing a King card
func set_king_state(flipped: bool) -> void:
    if flipped:
        king_destruction = sword_stats.king_modifier
        DebugManager.print_card_effects("SwordCalculator: King (flipped) - set %d destruction charges" % king_destruction, DebugManager.DebugLevel.INFO)
    else:
        king_protection = sword_stats.king_modifier
        DebugManager.print_card_effects("SwordCalculator: King (upright) - set %d protection charges" % king_protection, DebugManager.DebugLevel.INFO)

# Check if any page charge is active
func has_page_charge() -> bool:
    return (page_pos_charges > 0 or page_neg_charges > 0)

# Apply and consume a page charge if present
func apply_page_charge(value: int) -> int:
    if page_pos_charges > 0:
        page_pos_charges -= 1
        var new_value = value * sword_stats.page_multiplier
        DebugManager.print_card_effects("SwordCalculator: Applied positive page charge - value multiplied from %d to %d (charges left: %d)" % [value, new_value, page_pos_charges], DebugManager.DebugLevel.INFO)
        return new_value
    elif page_neg_charges > 0:
        page_neg_charges -= 1
        var new_value = int(float(value) / float(sword_stats.page_multiplier))
        DebugManager.print_card_effects("SwordCalculator: Applied negative page charge - value divided from %d to %d (charges left: %d)" % [value, new_value, page_neg_charges], DebugManager.DebugLevel.INFO)
        return new_value
    return value

# Public method to update combo for a new card
func update_swords(flipped: bool) -> void:
    update_combo(flipped)


# Returns the value, inverted if flipped, and applies page effect if active
# Override for Sword-specific value modification logic
func _value_modifier(value: int, flipped: bool = false) -> int:
    var updated_value: int = -value if flipped else value
    if has_page_charge():
        updated_value = apply_page_charge(updated_value)
    return updated_value

func calculate_base_value(card: Card, _flipped: bool) -> int:
    # Apply integer bonuses first
    var base_result = card.value + sword_stats.basic_value

    # Then apply multiplicative bonus
    var result = base_result * sword_stats.basic_value_multiplier

    # Apply synergy multipliers if available
    if game_state and game_state.stats:
        result *= game_state.stats.swords_combo_bonus
        result *= game_state.stats.arcana_synergy_multiplier

    var final_result = int(result)
    DebugManager.print_card_effects("SwordCalculator: Base value calculated - card: %d + basic: %d = %d, multiplier: %.3f, swords_combo: %.3f, arcana_synergy: %.3f, final: %d" % [card.value, sword_stats.basic_value, base_result, sword_stats.basic_value_multiplier, game_state.stats.swords_combo_bonus if game_state and game_state.stats else 1.0, game_state.stats.arcana_synergy_multiplier if game_state and game_state.stats else 1.0, final_result], DebugManager.DebugLevel.VERBOSE)
    return final_result

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    var result = _route_card_calculation(card, base_value, flipped)
    DebugManager.print_card_effects("SwordCalculator: Main calculation completed - card: %s (flipped: %s), combo: %d, result: %d" % [Tools.get_card_title(card), str(flipped), combo, result], DebugManager.DebugLevel.INFO)
    return result

# Basic Swords card calculation
func _basic(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    return get_combo() * val

# Page Swords card calculation
func _page(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    add_page_charge(flipped)
    return get_combo() * val

# Knight Swords card calculation
func _knight(base_value: int, flipped: bool) -> int:
    var base_val = _value_modifier(base_value, flipped)
    var multiplied_val = int(base_val * sword_stats.knight_multiplier)
    DebugManager.print_card_effects("SwordCalculator: Knight multiplier applied - base: %d * %.3f = %d" % [base_val, sword_stats.knight_multiplier, multiplied_val], DebugManager.DebugLevel.VERBOSE)
    # For each combo, add or remove a card lower than knight_mod (optionally using knight_super)
    for i in range(get_combo()):
        if game_state.deck_manager:
            if flipped:
                game_state.deck_manager.remove_lower_than(sword_stats.knight_modifier, sword_stats.knight_super)
            else:
                game_state.deck_manager.add_lower_than(sword_stats.knight_modifier, sword_stats.knight_super)
    return get_combo() * multiplied_val

# Queen Swords card calculation
func _queen(base_value: int, flipped: bool) -> int:
    adjust_combo_value_for_queen(flipped)
    var base_val = _value_modifier(base_value, flipped)
    var multiplied_val = int(base_val * sword_stats.queen_multiplier)
    DebugManager.print_card_effects("SwordCalculator: Queen multiplier applied - base: %d * %.3f = %d" % [base_val, sword_stats.queen_multiplier, multiplied_val], DebugManager.DebugLevel.VERBOSE)
    return get_combo() * multiplied_val

# King Swords card calculation
func _king(base_value: int, flipped: bool) -> int:
    var base_val = _value_modifier(base_value, flipped)
    var multiplied_val = int(base_val * sword_stats.king_multiplier)
    DebugManager.print_card_effects("SwordCalculator: King multiplier applied - base: %d * %.3f = %d" % [base_val, sword_stats.king_multiplier, multiplied_val], DebugManager.DebugLevel.VERBOSE)
    set_king_state(flipped)
    return get_combo() * multiplied_val

### --- Utility ---
func get_display_state() -> Dictionary:
    var dict = {
        "combo": combo,
        "combo_value": combo_value,
        "page_positive_charges": page_pos_charges,
        "page_negative_charges": page_neg_charges,
        "king_protection": king_protection,
        "king_destruction": king_destruction,
    }
    return dict

func get_state_backup() -> Dictionary:
    return get_display_state()

func restore_state_backup(backup: Dictionary):
    if backup.has("combo"):
        combo = backup["combo"]
    if backup.has("combo_dir_flipped"):
        combo_dir_flipped = backup["combo_dir_flipped"]
    if backup.has("combo_value"):
        combo_value = backup["combo_value"]
    if backup.has("page_pos_charges"):
        page_pos_charges = backup["page_pos_charges"]
    if backup.has("page_neg_charges"):
        page_neg_charges = backup["page_neg_charges"]
    if backup.has("king_protection"):
        king_protection = backup["king_protection"]
    if backup.has("king_destruction"):
        king_destruction = backup["king_destruction"]

### --- Death Reset ---
func death_reset(clear_positive: bool) -> int:
    var effects_cleared: int = 0
    
    if clear_positive:
        # Clear positive sword effects
        if combo > 1:
            combo = 1
            effects_cleared += 1
        if combo_value > 1:
            combo_value = 1
            effects_cleared += 1
        if page_pos_charges > 0:
            page_pos_charges = 0
            effects_cleared += 1
        if king_protection > 0:
            king_protection = 0
            effects_cleared += 1
    else:
        # Clear negative sword effects  
        if page_neg_charges > 0:
            page_neg_charges = 0
            effects_cleared += 1
        if king_destruction > 0:
            king_destruction = 0
            effects_cleared += 1
    
    return effects_cleared