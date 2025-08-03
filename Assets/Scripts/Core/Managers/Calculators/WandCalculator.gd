extends BaseCalculator
class_name WandCalculator 

var current_value: int = 0
var page_charges: int = 0
var knight_charges: int = 0

func calculate_base_value(card: DataStructures.Card, flipped: bool) -> int:
    var stats = game_state.stats.wand_stats
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
    var stats = game_state.stats.wand_stats
    var modifier = stats.page_modifier
    
    if flipped:
        modifier = -modifier
    
    page_charges += modifier
    return base_value + page_charges

func _calculate_knight_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.wand_stats
    var modifier = stats.knight_modifier
    
    if flipped:
        modifier = -modifier
    
    knight_charges += modifier
    return base_value + knight_charges

func _calculate_queen_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.wand_stats
    var modifier = stats.queen_modifier
    
    if flipped:
        modifier = -modifier
    
    current_value += modifier
    return base_value + current_value

func _calculate_king_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.wand_stats
    var modifier = stats.king_modifier
    
    # King doubles all accumulated values
    return (current_value + page_charges + knight_charges) * modifier

func get_state_backup() -> Dictionary:
    return {
        "current_value": current_value,
        "page_charges": page_charges,
        "knight_charges": knight_charges
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("current_value"):
        current_value = backup["current_value"]
    if backup.has("page_charges"):
        page_charges = backup["page_charges"]
    if backup.has("knight_charges"):
        knight_charges = backup["knight_charges"]