extends BaseCalculator
class_name SwordCalculator 

var combo: int = 0
var combo_value: int = 0
var page_charges: int = 0
var king_protection: bool = false

func calculate_base_value(card: DataStructures.Card, flipped: bool) -> int:
    var stats = game_state.stats.sword_stats
    return card.value + stats.basic_value

func calculate_main_value(card: DataStructures.Card, base_value: int, flipped: bool) -> int:
    match card.value:
        11:  # Page
            return _calculate_page_value(base_value, flipped)
        12:  # Knight
            return _calculate_knight_value(base_value, flipped)
        13:  # Queen
            return _calculate_queen_value(base_value, flipped)
        14:  # King
            return _calculate_king_value(base_value, flipped)
        _:
            return base_value

func _calculate_page_value(base_value: int, flipped: bool) -> int:
    page_charges += 1
    combo += 1
    combo_value += base_value
    
    return combo_value

func _calculate_knight_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.sword_stats
    var modifier = stats.knight_modifier
    
    if flipped:
        modifier = -modifier
    
    combo += 1
    combo_value += base_value * modifier
    
    return combo_value

func _calculate_queen_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.sword_stats
    var modifier = stats.queen_modifier
    
    if flipped:
        modifier = -modifier
    
    # Queen resets combo but multiplies final value
    var final_value = combo_value * modifier
    combo = 0
    combo_value = 0
    
    return final_value

func _calculate_king_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.sword_stats
    var modifier = stats.king_modifier
    
    king_protection = true
    return combo_value * modifier

func get_state_backup() -> Dictionary:
    return {
        "combo": combo,
        "combo_value": combo_value,
        "page_charges": page_charges,
        "king_protection": king_protection
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("combo"):
        combo = backup["combo"]
    if backup.has("combo_value"):
        combo_value = backup["combo_value"]
    if backup.has("page_charges"):
        page_charges = backup["page_charges"]
    if backup.has("king_protection"):
        king_protection = backup["king_protection"]