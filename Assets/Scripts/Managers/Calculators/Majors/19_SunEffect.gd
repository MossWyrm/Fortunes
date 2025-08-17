extends MajorEffectBase
class_name SunEffect

"""
=== The Sun ===
When drawn:
- If upright (not flipped): adds major_sun_star (card 518) and major_sun_moon (card 519) to the deck.
- If reversed (flipped): removes all copies of card 518 and 519 from the deck.
- Sets state to POSITIVE (upright) or NEGATIVE (flipped) in MajorCalculator.
- Always triggers a major card animation.
In post-calc, Sun does not directly modify value.
"""

func apply(card: Card, flipped: bool) -> int:
	state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	if flipped:
		# Remove all copies of 518 and 519
		game_state.deck_manager.remove_all_copies(518)
		game_state.deck_manager.remove_all_copies(519)
	else:
		# Add major_sun_star (518) and major_sun_moon (519)
		for i in game_state.stats.major_stats.sun_star:
			game_state.deck_manager.add_card(518)
		for i in game_state.stats.major_stats.sun_moon:
			game_state.deck_manager.add_card(519)
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0