extends BaseCalculator
class_name MajorCalculator 

var major_states: Dictionary = {}
var empress_collection: Array[int] = []
var chariot_tracker: Array[int] = []

func calculate_base_value(card: DataStructures.Card, flipped: bool) -> int:
    # Major Arcana typically have no base value
    return 0

func calculate_main_value(card: DataStructures.Card, base_value: int, flipped: bool) -> int:
    match card.value:
        1:   # Fool
            return _calculate_fool_value(base_value, flipped)
        2:   # Magician
            return await _calculate_magician_value(base_value, flipped)
        3:   # High Priestess
            return await _calculate_high_priestess_value(base_value, flipped)
        # Add more major arcana calculations as needed
        _:
            return base_value

func _calculate_fool_value(base_value: int, flipped: bool) -> int:
    # Fool gives random value
    return randi_range(-10, 10)

func _calculate_magician_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.major_stats
    var value = stats.magician
    
    if flipped:
        value = -value
    
    return value

func _calculate_high_priestess_value(base_value: int, flipped: bool) -> int:
    var stats = game_state.stats.major_stats
    var count = stats.high_priestess
    
    if flipped:
        # Hide cards
        pass
    else:
        # Reveal cards
        var revealed_cards = game_state.deck_manager.peek_multiple_cards(count)
        # Handle card revelation logic
    
    return 0

func get_state_backup() -> Dictionary:
    return {
        "major_states": major_states.duplicate(true),
        "empress_collection": empress_collection.duplicate(),
        "chariot_tracker": chariot_tracker.duplicate()
    }

func restore_state_backup(backup: Dictionary):
    if backup.has("major_states"):
        major_states = backup["major_states"]
    if backup.has("empress_collection"):
        empress_collection = backup["empress_collection"]
    if backup.has("chariot_tracker"):
        chariot_tracker = backup["chariot_tracker"] 