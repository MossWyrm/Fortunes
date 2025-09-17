extends MajorEffectBase
class_name TemperanceEffect

"""
=== Temperance ===
Provides permanent value clamping to prevent extreme outcomes.

Upright: Raises all card values to at least the temperance threshold.
Protects against bad luck streaks and negative effects.

Reversed: Lowers all card values to at most the temperance threshold.
Provides consistency over high variance, useful for careful play.

Applied in post-calculation phase after all other effects.
Embodies balance by preventing both extreme lows and extreme highs.
"""

func apply(_card: Card, flipped: bool) -> int:
	# Set card_state and value when Temperance is drawn
	var threshold = game_state.stats.major_stats.temperance
	if flipped:
		card_state = DataStructures.CardState.NEGATIVE
		DebugManager.print_card_effects(str("[TemperanceEffect] REVERSED TEMPERANCE - Setting maximum ceiling at ", 
			  threshold), DebugManager.DebugLevel.INFO)
	else:
		card_state = DataStructures.CardState.POSITIVE
		DebugManager.print_card_effects(str("[TemperanceEffect] UPRIGHT TEMPERANCE - Setting minimum floor at ", 
			  threshold), DebugManager.DebugLevel.INFO)
	
	return 0

func get_value(_value: int = 0) -> int:
	# Return the temperance threshold for display purposes
	return game_state.stats.major_stats.temperance

func apply_temperance_to_card(value: int) -> int:
	var threshold = game_state.stats.major_stats.temperance
	var result = value
	
	if card_state == DataStructures.CardState.POSITIVE:
		result = value if value >= threshold else threshold
		if result != value:
			DebugManager.print_card_effects(str("[TemperanceEffect] BALANCE APPLIED - Raised ", value, 
				  " to minimum ", threshold), DebugManager.DebugLevel.INFO)
		else:
			DebugManager.print_card_effects(str("[TemperanceEffect] No balance needed - ", value, 
				  " already >= ", threshold), DebugManager.DebugLevel.VERBOSE)
	elif card_state == DataStructures.CardState.NEGATIVE:
		result = value if value <= threshold else threshold
		if result != value:
			DebugManager.print_card_effects(str("[TemperanceEffect] BALANCE APPLIED - Lowered ", value, 
				  " to maximum ", threshold), DebugManager.DebugLevel.INFO)
		else:
			DebugManager.print_card_effects(str("[TemperanceEffect] No balance needed - ", value, 
				  " already <= ", threshold), DebugManager.DebugLevel.VERBOSE)
	else:
		DebugManager.print_card_effects(str("[TemperanceEffect] Inactive - no balance applied to ", value), 
			  DebugManager.DebugLevel.VERBOSE)
	
	return result

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE