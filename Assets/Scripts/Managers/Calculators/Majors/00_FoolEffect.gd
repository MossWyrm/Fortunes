extends MajorEffectBase
class_name FoolEffect

"""
=== The Fool ===
Forces a deck shuffle (safe if upright, normal if reversed).
No direct value is awarded.
"""

func apply(_card: Card, flipped: bool) -> int:
	var is_safe_shuffle = !flipped
	DebugManager.print_card_effects(str("[FoolEffect] THE FOOL'S JOURNEY - Triggering ", 
		  "safe shuffle (preserving effects)" if is_safe_shuffle else "chaotic shuffle (resetting effects)"), 
		  DebugManager.DebugLevel.INFO)
	
	EventBus.emit_request_shuffle(is_safe_shuffle)
	return 0
