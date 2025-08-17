extends MajorEffectBase
class_name EmpressEffect

"""
=== The Empress ===
When drawn, sets the Empress state to POSITIVE (upright) or NEGATIVE (reversed).
Tracks the most recent X values (X = MajorStats.empress) added via update_empress(value).
The Empress value is the sum of the collection, multiplied by +1 or -1 depending on state.
Always triggers a major card animation.
"""

var empress_collection: Array[int] = []

func apply(_card: Card, flipped: bool) -> int:
    # Set the Empress state using the generic major state system and shared enum
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    state = set_state
    game_state.event_bus.emit_major_card_animation_requested(flipped)
    return 0

func update(value: int) -> void:
    if value == 0 or state == DataStructures.CardState.INACTIVE:
        return
    empress_collection.append(abs(value))
    while empress_collection.size() > game_state.stats.major_stats.empress:
        empress_collection.pop_front()  # Keep the collection size limited to MajorStats.empress

func get_value(_additional_val: int = 0) -> int:
    if state == DataStructures.CardState.INACTIVE:
        return 0
    var output = empress_collection.reduce(func(accum, number): return accum + number, 0)
    if state == DataStructures.CardState.NEGATIVE:
        output = -output  # Negate the value if in negative state
    return output

func reset() -> void:
    state = DataStructures.CardState.INACTIVE
    empress_collection.clear()


func get_state_backup() -> Dictionary:
    return {
        "state": state,
        "empress_collection": empress_collection.duplicate()
    }

func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("state"):
        state = backup["state"]
    if backup.has("empress_collection"):
        empress_collection = backup["empress_collection"].duplicate()