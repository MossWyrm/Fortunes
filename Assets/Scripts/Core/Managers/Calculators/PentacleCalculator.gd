extends BaseCalculator
class_name PentacleCalculator

var protection_value: int = 0
var charges: int = 0
var queen_charges: int = 0
var queen_inverted: bool = false

func calculate_base_value(card: DataStructures.Card, flipped: bool) -> int:
    var stats = game_state.stats.pentacle_stats
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
    var stats = game_state.stats.pentacle_stats
    var modifier = stats.page_modifier
    
    if flipped:
        modifier = -modifier
    
    protection_value += int(base_value * modifier)
    return protection_value

func _calculate_knight_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.pentacle_stats
    var uses = stats.knight_uses
    
    if charges < uses:
        charges += 1
        return base_value + protection_value
    else:
        return base_value

func _calculate_queen_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.pentacle_stats
    var uses = stats.queen_uses
    
    if queen_charges < uses:
        queen_charges += 1
        queen_inverted = flipped
        return base_value + protection_value
    else:
        return base_value

func _calculate_king_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.pentacle_stats
    var uses = stats.king_uses
    var value = stats.king_value
    
    if charges >= uses:
        charges -= uses
        return value
    else:
        return base_value

func get_state_backup() -> Dictionary:
    return {
        "protection_value": protection_value,
        "charges": charges,
        "queen_charges": queen_charges,
        "queen_inverted": queen_inverted
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("protection_value"):
        protection_value = backup["protection_value"]
    if backup.has("charges"):
        charges = backup["charges"]
    if backup.has("queen_charges"):
        queen_charges = backup["queen_charges"]
    if backup.has("queen_inverted"):
        queen_inverted = backup["queen_inverted"]