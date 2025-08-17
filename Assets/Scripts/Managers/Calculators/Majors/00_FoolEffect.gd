extends MajorEffectBase
class_name FoolEffect

"""
=== The Fool ===
Forces a deck shuffle (normal if upright, safe if reversed) and triggers a major card animation.
No direct value is awarded.
"""

func apply(card: Card, flipped: bool) -> int:
	# This card forces a shuffle of the deck using the new event bus architecture
	game_state.event_bus.emit_request_shuffle(!flipped)
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0
