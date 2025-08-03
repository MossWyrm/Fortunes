extends BaseCalculator
class_name CupCalculator 

var vessels: Array[int] = []
var current_vessel: int = 0

func _init():
    vessels = [0]  # Start with one vessel

func calculate_base_value(_card: DataStructures.Card, _flipped: bool) -> int:
    var stats = game_state.stats.cup_stats
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
    var stats = game_state.stats.cup_stats
    var vessel_size = stats.vessel_size
    var modifier = stats.page_modifier
    
    if flipped:
        modifier = -modifier
    
    # Fill current vessel
    vessels[current_vessel] += base_value
    
    # Check if vessel is full
    if vessels[current_vessel] >= vessel_size:
        var overflow = vessels[current_vessel] - vessel_size
        vessels[current_vessel] = vessel_size
        return int(vessel_size * modifier) + overflow
    else:
        return int(vessels[current_vessel] * modifier)

func _calculate_knight_value(_base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.cup_stats
    var modifier = stats.knight_modifier
    
    if flipped:
        modifier = -modifier
    
    # Empty all vessels
    var total_value = 0
    for i in range(vessels.size()):
        total_value += vessels[i]
        vessels[i] = 0
    
    return total_value * modifier

func _calculate_queen_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.cup_stats
    var modifier = stats.queen_modifier
    
    if flipped:
        modifier = -modifier
    
    # Add new vessel
    vessels.append(0)
    
    return base_value * modifier

func _calculate_king_value(base_value: int, flipped: bool) -> int:
    # King doubles all vessel values
    var total_value = 0
    for vessel in vessels:
        total_value += vessel * 2
    
    return total_value

func get_state_backup() -> Dictionary:
    return {
        "vessels": vessels.duplicate(),
        "current_vessel": current_vessel
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("vessels"):
        vessels = backup["vessels"]
    if backup.has("current_vessel"):
        current_vessel = backup["current_vessel"]