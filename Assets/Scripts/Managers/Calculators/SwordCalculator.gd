
extends BaseCalculator
class_name SwordCalculator


### --- State ---
var sword_stats: SwordStats
var combo: int = 1
var combo_dir_flipped: bool = false
var combo_value: int = 1
var page_pos_charges: int = 0
var page_neg_charges: int = 0
var king_protection: int = 0
var king_destruction: int = 0


### --- Initialization ---
func set_game_state(state: GameState):
    super.set_game_state(state)
    assert(state and state.stats and state.stats.sword_stats, "SwordCalculator requires sword_stats to be present in GameState!")
    sword_stats = state.stats.sword_stats

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
    if safely:
        return
    combo = 1
    combo_dir_flipped = false
    combo_value = 1
    page_pos_charges = 0
    page_neg_charges = 0
    king_protection = 0
    king_destruction = 0
    
# Update combo and king state for a new card direction
func update_combo(flipped: bool) -> void:
    if combo_dir_flipped == flipped:
        if king_destruction > 0:
            king_destruction -= 1
        else:
            combo += combo_value
    else:
        if king_protection > 0:
            king_protection -= 1
        else:
            combo = 1
            combo_dir_flipped = flipped

# Get current combo multiplier
func get_combo() -> int:
    return combo

# Handle drawing a Page card
func add_page_charge(flipped: bool) -> void:
    if flipped:
        page_neg_charges += sword_stats.page_modifier
    else:
        page_pos_charges += sword_stats.page_modifier

# Handle drawing a Queen card
func adjust_combo_value_for_queen(flipped: bool) -> void:
    combo_value += sword_stats.queen_modifier if not flipped else -sword_stats.queen_modifier
    if combo_value < 0:
        combo_value = 0

# Handle drawing a King card
func set_king_state(flipped: bool) -> void:
    if flipped:
        king_destruction = sword_stats.king_modifier
    else:
        king_protection = sword_stats.king_modifier

# Check if any page charge is active
func has_page_charge() -> bool:
    return (page_pos_charges > 0 or page_neg_charges > 0)

# Apply and consume a page charge if present
func apply_page_charge(value: int) -> int:
    if page_pos_charges > 0:
        page_pos_charges -= 1
        return value * 2
    elif page_neg_charges > 0:
        page_neg_charges -= 1
        return int(float(value) / 2.0)
    return value

# Public method to update combo for a new card
func update_swords(flipped: bool) -> void:
    update_combo(flipped)

### --- Calculation Methods ---

# Returns the value, inverted if flipped, and applies page effect if active
# Override for Sword-specific value modification logic
func _value_modifier(value: int, flipped: bool = false) -> int:
    var updated_value: int = -value if flipped else value
    if has_page_charge():
        updated_value = apply_page_charge(updated_value)
    return updated_value

func calculate_base_value(card: Card, _flipped: bool) -> int:
    return card.value + sword_stats.basic_value


func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
    return _route_card_calculation(card, base_value, flipped)

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
    var val = _value_modifier(base_value, flipped)
    # For each combo, add or remove a card lower than knight_mod (optionally using knight_super)
    for i in range(get_combo()):
        if game_state.deck_manager:
            if flipped:
                game_state.deck_manager.remove_lower_than(sword_stats.knight_mod, sword_stats.knight_super)
            else:
                game_state.deck_manager.add_lower_than(sword_stats.knight_mod, sword_stats.knight_super)
    return get_combo() * val

# Queen Swords card calculation
func _queen(base_value: int, flipped: bool) -> int:
    adjust_combo_value_for_queen(flipped)
    var val = _value_modifier(base_value, flipped)
    return get_combo() * val

# King Swords card calculation
func _king(base_value: int, flipped: bool) -> int:
    var val = _value_modifier(base_value, flipped)
    set_king_state(flipped)
    return get_combo() * val

### --- Utility ---
func get_display_state() -> Dictionary:
    return {
        "combo": combo,
        "combo_value": combo_value,
        "page_positive_charges": page_pos_charges,
        "page_negative_charges": page_neg_charges,
        "king_protection": king_protection,
        "king_destruction": king_destruction,
    }

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