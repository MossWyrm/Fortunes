extends MajorEffectBase
class_name MagicianEffect

"""
=== The Magician ===
Prompts the player to choose a suit. For each major_magician stat:
- Upright: Adds x cards of that suit to the deck
- Reversed: Removes x cards of that suit from the deck
"""

func apply(_card: Card, flipped: bool) -> int:
	EventBus.emit_suit_choice_requested(false)
	var suit = await EventBus.suit_chosen
	var count = game_state.stats.major_stats.magician
	for i in range(count):
		if flipped:
			game_state.deck_manager.remove_random_card_by_suit(suit)
		else:
			game_state.deck_manager.add_random_card_by_suit(suit)
	return 0
