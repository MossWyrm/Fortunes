extends MajorEffectBase
class_name EmperorEffect

"""
=== The Emperor ===
When drawn, sets the Emperor state to POSITIVE (upright) or NEGATIVE (reversed).
The Emperor increases the value of all cards by MajorStats.emperor (positive or negative based on state).
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
	# Set the Emperor state using the generic major state system and shared enum
	var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	state = set_state
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0

# Returns the Emperor's effect value based on state.
func get_value(_additional_val: int = 0) -> int:
	match state:
		DataStructures.CardState.POSITIVE:
			return game_state.stats.major_stats.emperor
		DataStructures.CardState.NEGATIVE:
			return -game_state.stats.major_stats.emperor
		_:
			return 0
