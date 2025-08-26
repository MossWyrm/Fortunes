extends MajorEffectBase
class_name StrengthEffect

"""
=== Strength ===
When drawn, sets the Strength card_state to POSITIVE (upright) or NEGATIVE (reversed).
Sets the charges for Strength to MajorStats.strength.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    card_state = set_state
    EventBus.emit_major_card_animation_requested(flipped)
    return 0
