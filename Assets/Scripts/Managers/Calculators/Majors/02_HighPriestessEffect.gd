extends MajorEffectBase
class_name HighPriestessEffect

"""
=== The High Priestess (Modified Effect) ===
Shows the next X cards in the deck (X = MajorStats.high_priestess).
Upright: Sets all their values to the highest among them.
Reversed: Sets all their values to the lowest among them.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
	var count = game_state.stats.major_stats.high_priestess
	var cards = game_state.deck_manager.peek_multiple_cards(count)
	if cards.is_empty():
		return 0
	# Show the cards to the player (UI event, if available)
	if game_state.event_bus:
		game_state.event_bus.emit_show_revealed_cards(cards)
	# Simulate each card and collect their final_value and card reference
	var sim_results = []
	for c in cards:
		var sim_result = await game_state.card_calculator.simulate_card_logic(c, flipped)
		sim_results.append({"card": c, "final_value": sim_result["final_value"]})
	# Find the best/worst card
	var chosen = sim_results[0]
	for r in sim_results:
		if flipped:
			if r["final_value"] < chosen["final_value"]:
				chosen = r
		else:
			if r["final_value"] > chosen["final_value"]:
				chosen = r
	# Make all cards exact copies of the chosen card
	for c in cards:
		if c != chosen["card"]:
			c.copy_from(chosen["card"])
			print("High Priestess: Copied card ", chosen["card"].id, " to card ", c.id)
	# Animation event
	if game_state.event_bus:
		game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0
