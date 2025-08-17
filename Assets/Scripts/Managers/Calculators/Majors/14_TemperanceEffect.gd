extends MajorEffectBase
class_name TemperanceEffect

"""
=== Temperance ===
When drawn, sets state to POSITIVE (upright) or NEGATIVE (reversed).
In post-calc, if upright, raises value to at least temperance stat; if reversed, lowers value to at most temperance stat.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
	# Set state and value when Temperance is drawn
	if flipped:
		state = DataStructures.CardState.NEGATIVE
	else:
		state = DataStructures.CardState.POSITIVE
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(value: int = 0) -> int:
	if state == DataStructures.CardState.POSITIVE:
		return value if value >= game_state.stats.major_stats.temperance else game_state.stats.major_stats.temperance
	elif state == DataStructures.CardState.NEGATIVE:
		return value if value <= game_state.stats.major_stats.temperance else game_state.stats.major_stats.temperance
	return value