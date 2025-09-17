extends MajorEffectBase
class_name EmpressEffect

"""
=== The Empress ===
When drawn, sets the Empress card_state to POSITIVE (upright) or NEGATIVE (reversed).
Tracks the most recent X values (X = MajorStats.empress) added via update_empress(value).
The Empress value is the sum of the collection, multiplied by +1 or -1 depending on card_state.
Always triggers a major card animation.
"""

var empress_collection: Array[int] = []

func apply(_card: Card, flipped: bool) -> int:
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    card_state = set_state
    
    DebugManager.print_card_effects(str("[EmpressEffect] THE EMPRESS AWAKENS - ", 
          "Draining abundance" if flipped else "Growing abundance", 
          ", Tracking capacity: ", game_state.stats.major_stats.empress), DebugManager.DebugLevel.INFO)
    
    return 0

func update(value: int) -> void:
    if value == 0 or card_state == DataStructures.CardState.INACTIVE:
        return
    
    var old_total = empress_collection.reduce(func(accum, number): return accum + number, 0)
    var capacity = game_state.stats.major_stats.empress
    
    empress_collection.append(abs(value))
    while empress_collection.size() > capacity:
        empress_collection.pop_front()  # Keep the collection size limited to MajorStats.empress
    
    var new_total = empress_collection.reduce(func(accum, number): return accum + number, 0)
    DebugManager.print_card_effects(str("[EmpressEffect] ABUNDANCE GROWS - Added ", abs(value), 
          ", Collection: ", empress_collection, ", Total: ", old_total, " → ", new_total), 
          DebugManager.DebugLevel.VERBOSE)

func get_value(_additional_val: int = 0) -> int:
    if card_state == DataStructures.CardState.INACTIVE:
        return 0
    var output = empress_collection.reduce(func(accum, number): return accum + number, 0)
    if card_state == DataStructures.CardState.NEGATIVE:
        output = -output  # Negate the value if in negative card_state
    return output

func modify_card_value(input_value: int) -> int:
    DebugManager.print_card_effects(str("[EmpressEffect] APPLYING ABUNDANCE - ", input_value, 
          "+ ", get_value(), "(bonus) = ", input_value + get_value()), DebugManager.DebugLevel.INFO)
    return input_value + get_value()

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE
    empress_collection.clear()

func get_state_backup() -> Dictionary:
    return {
        "card_state": card_state,
        "empress_collection": empress_collection.duplicate()
    }

func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("card_state"):
        card_state = backup["card_state"]
    if backup.has("empress_collection"):
        empress_collection = backup["empress_collection"].duplicate()