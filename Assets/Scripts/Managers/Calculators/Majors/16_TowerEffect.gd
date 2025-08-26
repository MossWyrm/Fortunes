extends MajorEffectBase
class_name TowerEffect

"""
=== The Tower ===
When drawn, if not already active, set card_state to POSITIVE (upright) or NEGATIVE (reversed) and add card 517 to the deck.
If already active, toggle the card_state.
In post-calc: 
  - If POSITIVE, multiply value by major_tower stat.
  - If NEGATIVE, divide value by major_tower stat (rounded down).
  - Otherwise, return value unchanged.
Always triggers a major card animation.
"""
func apply(_card: Card, flipped: bool) -> int:
	# If already active, toggle card_state
	if card_state != DataStructures.CardState.INACTIVE:
		if card_state == DataStructures.CardState.NEGATIVE:
			card_state = DataStructures.CardState.POSITIVE
		else:
			card_state = DataStructures.CardState.NEGATIVE
	else:
		card_state = DataStructures.CardState.POSITIVE if !flipped else DataStructures.CardState.NEGATIVE
		game_state.deck_manager.add_card(517)
	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(value: int = 0) -> int:
	var output: int = 0
	match card_state:
		DataStructures.CardState.POSITIVE:
			output = value * game_state.stats.major_stats.tower
		DataStructures.CardState.NEGATIVE:
			output = int(float(value) / float(game_state.stats.major_stats.tower))
		_:
			output = value
	return output