extends MajorEffectBase
class_name StarEffect

"""
=== The Star ===
When drawn:
- Adds flat star_stat to accumulated star_value (or subtracts if inverted)
- Creates exponential scaling when combined with Moon/Sun: (star_value)^(1 + moons_drawn + sun_amplifier)
- Upright: +star_stat to star_value, Inverted: -star_stat to star_value
- Exponential bonus applies to every card drawn while Star is active
- Always triggers a major card animation.
"""

var star_value: int = 0
var works_on_negative: bool = false
var moons_drawn: int:
	get:
		return major_calc.get_major_effect(DataStructures.MAJOR_ID.MOON).moons_drawn

func apply(_card: Card, flipped: bool) -> int:
	# Set card state based on orientation
	card_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	
	# Simplified formula: each Star adds/subtracts flat star_stat
	var star_change = game_state.stats.major_stats.star
	if flipped:
		star_value -= star_change  # Fallen Star reduces power
		DebugManager.print_card_effects(str("[StarEffect] FALLEN STAR - Star value: ", star_value + star_change, 
			  " → ", star_value), DebugManager.DebugLevel.INFO)
	else:
		star_value += star_change  # Rising Star increases power
		DebugManager.print_card_effects(str("[StarEffect] RISING STAR - Star value: ", star_value - star_change, 
			  " → ", star_value), DebugManager.DebugLevel.INFO)
	
	# Log celestial synergy details
	var moon_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.MOON)
	var sun_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.SUN)
	var moon_contrib = moon_effect.get_moon_exponent_contribution() if moon_effect else 0
	var sun_contrib = sun_effect.get_sun_amplifier() if sun_effect else 0
	
	DebugManager.print_card_effects(str("[StarEffect] Celestial synergy - Moon contrib: ", moon_contrib, 
		  ", Sun contrib: ", sun_contrib, ", Total exponent: ", 1 + moon_contrib + sun_contrib), 
		  DebugManager.DebugLevel.VERBOSE)
	
	return 0

func get_value(_additional_val: int = 0) -> int:
	# Return the current power being applied to each card
	if card_state == DataStructures.CardState.INACTIVE:
		return 0
	
	var moon_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.MOON)
	var sun_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.SUN)
	
	var moon_contrib = moon_effect.get_moon_exponent_contribution() if moon_effect else 0
	var sun_contrib = sun_effect.get_sun_amplifier() if sun_effect else 0
	
	var exponent = 1 + moon_contrib + sun_contrib
	return int(pow(float(star_value), float(exponent)))

func apply_star_to_card(input_val: int) -> int:
	if card_state == DataStructures.CardState.INACTIVE:
		return input_val
	
	# Get contributions from each celestial effect
	var moon_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.MOON)
	var sun_effect = major_calc.get_major_effect(DataStructures.MAJOR_ID.SUN)
	
	var moon_contrib = moon_effect.get_moon_exponent_contribution() if moon_effect else 0
	var sun_contrib = sun_effect.get_sun_amplifier() if sun_effect else 0
	
	# Your intended formula: (star_accum)^(1 + moon_contrib + sun_contrib)
	var exponent = 1 + moon_contrib + sun_contrib
	var value_modifier = int(pow(float(star_value), float(exponent)))
	
	var result: int
	if input_val > 0:
		result = value_modifier + input_val
	else:
		result = input_val - value_modifier
	
	DebugManager.print_card_effects(str("[StarEffect] Celestial formula: ", star_value, "^", exponent, 
		  " = ", value_modifier, ", Input: ", input_val, " → ", result), DebugManager.DebugLevel.VERBOSE)
	
	return result

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	star_value = 0
	works_on_negative = false

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"star_value": star_value,
		"works_on_negative": works_on_negative
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("star_value"):
		star_value = backup["star_value"]
	if backup.has("works_on_negative"):
		works_on_negative = backup["works_on_negative"]