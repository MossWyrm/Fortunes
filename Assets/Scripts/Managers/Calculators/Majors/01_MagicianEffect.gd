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
	
	DebugManager.print_card_effects(str("[MagicianEffect] THE MAGICIAN - ", 
		  "Banishing" if flipped else "Manifesting", " ", count, " cards of suit ", suit), 
		  DebugManager.DebugLevel.INFO)
	
	for i in range(count):
		if flipped:
			var _removed = game_state.deck_manager.remove_random_card_by_suit(suit)
			DebugManager.print_card_effects(str("[MagicianEffect] Banished card ", i+1, "/", count, 
				  " of suit ", suit), DebugManager.DebugLevel.VERBOSE)
		else:
			game_state.deck_manager.add_random_card_by_suit(suit)
			DebugManager.print_card_effects(str("[MagicianEffect] Manifested card ", i+1, "/", count, 
				  " of suit ", suit), DebugManager.DebugLevel.VERBOSE)
	
	DebugManager.print_card_effects(str("[MagicianEffect] Manifestation complete - ", count, 
		  " cards ", "removed from" if flipped else "added to", " deck"), DebugManager.DebugLevel.INFO)
	return 0
