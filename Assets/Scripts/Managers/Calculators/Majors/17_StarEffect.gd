extends MajorEffectBase
class_name StarEffect

"""
=== The Star ===
When drawn:
- Adds charges to Star based on major_star * (major_moon ^ moons_drawn) if moons_drawn > 0, else major_star.
- Sets card_state to POSITIVE if Moon is not NEGATIVE, else NEGATIVE.
- In post-calc, adds the number of charges to the value if Star is active and (if flipped, only if stars_work_on_bad is true).
- Always triggers a major card animation.
"""

var star_value: int = 0
var works_on_negative: bool = false
var moons_drawn: int:
	get:
		return major_calc.get_major_effect_by_name(DataStructures.MAJOR_ID.MOON).moons_drawn

func apply(_card: Card, flipped: bool) -> int:
	# Use MajorCalculator's card_state and charge system for Star and Moon
	var moon_effect: MoonEffect = game_state.major_calculator.get_major_effect(DataStructures.MAJOR_ID.MOON)
	if flipped && works_on_negative:
		card_state = DataStructures.CardState.NEGATIVE
	else:
		card_state = DataStructures.CardState.POSITIVE
	# Calculate charges using moons_drawn and stats
	var charges_mult = int(pow(float(game_state.stats.major_stats.moon), float(moon_effect.moons_drawn))) if moon_effect.moons_drawn > 0 else 1
	var new_charges = game_state.stats.major_stats.star * charges_mult
	star_value += new_charges
	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(_additional_val: int = 0) -> int:
	var value_modifier: int = 0
	if moons_drawn > 0:
		value_modifier = int(pow(float(game_state.stats.major_stats.moon), float(moons_drawn)))
	else:
		value_modifier = star_value
	if card_state == DataStructures.CardState.INACTIVE:
		return _additional_val
	if _additional_val > 0:
		return value_modifier + _additional_val
	return _additional_val - value_modifier

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