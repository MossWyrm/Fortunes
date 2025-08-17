extends MajorEffectBase
class_name MagicianEffect

"""
=== The Magician ===
Prompts the player to choose a suit. For each major_magician stat:
- Upright: Adds a card of that suit to the deck
- Reversed: Removes a card of that suit from the deck
Always triggers a major card animation.
"""

func apply(card: Card, flipped: bool) -> int:
	game_state.event_bus.emit_suit_choice_requested(false)
	# Wait for the suit to be chosen (assume event_bus emits suit_chosen)
	var suit = await game_state.event_bus.suit_chosen
	var count = game_state.stats.major_stats.magician
	for i in range(count):
		if flipped:
			game_state.deck_manager.remove_random_card_by_suit(suit)
		else:
			game_state.deck_manager.add_random_card_by_suit(suit)
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0
