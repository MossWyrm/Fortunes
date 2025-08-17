extends MajorEffectBase
class_name WheelOfFortuneEffect

"""
=== Wheel of Fortune ===
When drawn, prompts the player to choose a suit. If the next card matches, applies a bonus; otherwise, a penalty.
Handles state and triggers animation.
"""

var awaiting_check := false
var wheel_suit : DataStructures.SuitType = DataStructures.SuitType.NONE
var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
    game_state.event_bus.emit_choose_suit()
    awaiting_check = true
    wheel_suit = await game_state.event_bus.chosen_suit
    game_state.event_bus.emit_major_card_animation_requested(flipped)
    return 0

# Called when a card is drawn to check for a match and apply bonus/penalty
func update(suit: int) -> void:
    if !awaiting_check:
        return
    var set_state: DataStructures.CardState = DataStructures.CardState.INACTIVE
    if wheel_suit == suit:
        # Apply bonus (add charges, show success particle, etc.)
        set_state = DataStructures.CardState.POSITIVE
        game_state.event_bus.emit_request_vfx(DataStructures.VFXType.CARD_SUCCESS)
        # Implement charge logic as needed
    else:
        set_state = DataStructures.CardState.NEGATIVE
        game_state.event_bus.emit_request_vfx(DataStructures.VFXType.CARD_FAILURE)
    charges += game_state.stats.major_stats.wheel_charges
    state = set_state
    awaiting_check = false

func get_value(value: int = 0) -> int:
    var output: int = 0
    if charges <= 0:
        state = DataStructures.CardState.INACTIVE
        return value
    match state:
        DataStructures.CardState.POSITIVE:
            output = (value * game_state.stats.major_stats.wheel_multiplier)
        DataStructures.CardState.NEGATIVE:
            output = int(float(value) / float(game_state.stats.major_stats.wheel_multiplier))
        _:
            output = value
            return output
    charges -= 1
    if charges <= 0:
        state = DataStructures.CardState.INACTIVE
    return output

func active() -> bool:
    return charges > 0

# Returns a dictionary representing the effect's state for backup
func get_state_backup() -> Dictionary:
    return {
        "state": state,
        "awaiting_check": awaiting_check,
        "wheel_suit": wheel_suit,
        "charges": charges
    }

# Restores the effect's state from a backup dictionary
func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("state"):
        state = backup["state"]
    if backup.has("awaiting_check"):
        awaiting_check = backup["awaiting_check"]
    if backup.has("wheel_suit"):
        wheel_suit = backup["wheel_suit"]
    if backup.has("charges"):
        charges = backup["charges"]