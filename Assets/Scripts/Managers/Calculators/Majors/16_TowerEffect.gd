extends MajorEffectBase
class_name TowerEffect

"""
=== The Tower ===
When drawn, if not already active, set state to POSITIVE (upright) or NEGATIVE (reversed) and add card 517 to the deck.
If already active, toggle the state.
In post-calc: 
  - If POSITIVE, multiply value by major_tower stat.
  - If NEGATIVE, divide value by major_tower stat (rounded down).
  - Otherwise, return value unchanged.
Always triggers a major card animation.
"""
func apply(card: Card, flipped: bool) -> int:
	# If already active, toggle state
	if state != DataStructures.CardState.INACTIVE:
		if state == DataStructures.CardState.NEGATIVE:
			state = DataStructures.CardState.POSITIVE
		else:
			state = DataStructures.CardState.NEGATIVE
	else:
		state = DataStructures.CardState.POSITIVE if !flipped else DataStructures.CardState.NEGATIVE
		game_state.deck_manager.add_card(517)
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(value: int = 0) -> int:
	var output: int = 0
	match state:
		DataStructures.CardState.POSITIVE:
			output = value * game_state.stats.major_stats.tower
		DataStructures.CardState.NEGATIVE:
			output = int(float(value) / float(game_state.stats.major_stats.tower))
		_:
			output = value
	return output