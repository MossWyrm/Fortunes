extends MajorEffectBase
class_name TemperanceEffect

"""
=== Temperance ===
When drawn, sets card_state to POSITIVE (upright) or NEGATIVE (reversed).
In post-calc, if upright, raises value to at least temperance stat; if reversed, lowers value to at most temperance stat.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
	# Set card_state and value when Temperance is drawn
	if flipped:
		card_state = DataStructures.CardState.NEGATIVE
	else:
		card_state = DataStructures.CardState.POSITIVE
	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(value: int = 0) -> int:
	if card_state == DataStructures.CardState.POSITIVE:
		return value if value >= game_state.stats.major_stats.temperance else game_state.stats.major_stats.temperance
	elif card_state == DataStructures.CardState.NEGATIVE:
		return value if value <= game_state.stats.major_stats.temperance else game_state.stats.major_stats.temperance
	return value