extends MajorEffectBase
class_name HierophantEffect

"""
=== The Hierophant (Blessing Effect) ===
When drawn, sets card_state to POSITIVE (upright) or NEGATIVE (reversed).
Provides guidance for the next X cards drawn (X = MajorStats.hierophant).

Upright: Each of the next X cards gains a bonus equal to their base value (doubled effect)
Reversed: Each of the next X cards loses value equal to half their base value (cursed)

Uses charges - each card drawn consumes one charge. Provides powerful but limited guidance.
Always triggers a major card animation.
"""

var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
	card_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	charges = game_state.stats.major_stats.hierophant
	
	DebugManager.print_card_effects(str("[HierophantEffect] THE HIEROPHANT SPEAKS - ", 
		  "Cursing" if flipped else "Blessing", " the next ", charges, " cards"), 
		  DebugManager.DebugLevel.INFO)
	
	return 0

func get_value(_input: int = 0) -> int:
	# Return charges for display purposes
	return charges

func modify_card_value(input: int) -> int:
	if charges <= 0 or card_state == DataStructures.CardState.INACTIVE:
		return input
	var old_charges = charges
	var output: int
	match card_state:
		DataStructures.CardState.POSITIVE:
			# Blessing: Double the card's value
			output = input * 2
			DebugManager.print_card_effects(str("[HierophantEffect] BLESSING - Card ", input, 
				  " doubled to ", output, " (", old_charges, " → ", charges-1, " charges)"), 
				  DebugManager.DebugLevel.INFO)
		DataStructures.CardState.NEGATIVE:
			# Curse: Reduce by half
			output = int(input * 0.5)
			DebugManager.print_card_effects(str("[HierophantEffect] CURSE - Card ", input, 
				  " halved to ", output, " (", old_charges, " → ", charges-1, " charges)"), 
				  DebugManager.DebugLevel.INFO)
		_:
			output = input
	
	# Consume charge after applying effect
	consume()
	return output

func consume() -> void:
	charges -= 1
	if charges <= 0:
		card_state = DataStructures.CardState.INACTIVE
		DebugManager.print_card_effects("[HierophantEffect] GUIDANCE COMPLETE - Hierophant effect deactivated", 
			  DebugManager.DebugLevel.INFO)


func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	charges = 0