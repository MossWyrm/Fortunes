extends MajorEffectBase
class_name StrengthEffect

"""
=== Strength ===
When drawn, sets the Strength state to POSITIVE (upright) or NEGATIVE (reversed).
Sets the charges for Strength to MajorStats.strength.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    state = set_state
    game_state.event_bus.emit_major_card_animation_requested(flipped)
    return 0
