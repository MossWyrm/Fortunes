extends MajorEffectBase
class_name HangedManEffect

"""
=== The Hanged Man (Bottom-Up Perspective) ===
The Hanged Man inverts your perspective on card values, seeing worth where others see weakness.

When drawn, The Hanged Man activates a charge-based effect that alters card values:

Upright (Enlightened Surrender): Clean mathematical inversion of card hierarchy
- Kings (14) become worth 1, Queens (13) become worth 2, etc.
- Aces (1) become worth 14, Twos (2) become worth 13, etc.
- Grants 5 charges of predictable inversion

Reversed (Chaotic Resistance): Unpredictable, chaotic transformation  
- Card values become random (1 to half original value)
- Usually worse than original, but sometimes lucky
- Grants 5 charges of chaotic transformation

Each charge is consumed when any non-major card is drawn.
Always triggers a major card animation.
"""

# Instance State
var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
	charges = GameManager.game_state.stats.major_stats.hanged_man
	card_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	
	DebugManager.print_card_effects(str("[HangedManEffect] HANGED MAN ACTIVATED - ", 
		  "Inverted perspective" if flipped else "Enlightened perspective", 
		  ", Charges: ", charges), DebugManager.DebugLevel.INFO)
	DebugManager.print_card_effects(str("[HangedManEffect] Will ", 
		  "invert" if flipped else "enlighten", " next ", charges, " non-major cards"), 
		  DebugManager.DebugLevel.VERBOSE)
	
	return 0

func is_hanged_man_active() -> bool:
	return charges > 0

func apply_hanged_man_to_base_value(card: Card, base_value: int) -> int:
	if not is_hanged_man_active() or card.suit == DataStructures.SuitType.MAJOR:
		return base_value
	
	# Consume a charge
	var old_charges = charges
	charges -= 1
	if charges <= 0:
		card_state = DataStructures.CardState.INACTIVE
		DebugManager.print_card_effects("[HangedManEffect] PERSPECTIVE SHIFT COMPLETE - Effect deactivated", 
			  DebugManager.DebugLevel.INFO)
	
	var new_card_value: int
	
	if card_state == DataStructures.CardState.POSITIVE:
		# Upright: Clean, predictable inversion (enlightened perspective)
		new_card_value = 15 - card.value
		DebugManager.print_card_effects(str("[HangedManEffect] ENLIGHTENED PERSPECTIVE - Card ", 
			  card.value, " inverted to ", new_card_value, " (", old_charges, " → ", charges, " charges)"), 
			  DebugManager.DebugLevel.INFO)
	else:
		# Reversed: Chaotic, unpredictable values (resisting the lesson creates chaos)
		# Random value between 1 and half the original value (usually worse, sometimes lucky)
		var max_chaos_value = max(1, card.value / 2.0)
		new_card_value = randi_range(1, int(max_chaos_value))
		DebugManager.print_card_effects(str("[HangedManEffect] CHAOTIC INVERSION - Card ", 
			  card.value, " chaos rolled ", new_card_value, " (range 1-", int(max_chaos_value), 
			  ") (", old_charges, " → ", charges, " charges)"), DebugManager.DebugLevel.INFO)
	
	return new_card_value

func get_value(_additional_val: int = 0) -> int:
	return charges

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	charges = 0

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"charges": charges
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("charges"):
		charges = backup["charges"]
