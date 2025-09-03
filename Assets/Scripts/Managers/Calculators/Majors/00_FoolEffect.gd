extends MajorEffectBase
class_name FoolEffect

"""
=== The Fool ===
Forces a deck shuffle (safe if upright, normal if reversed).
No direct value is awarded.
"""

func apply(_card: Card, flipped: bool) -> int:
	EventBus.emit_request_shuffle(!flipped)
	return 0
