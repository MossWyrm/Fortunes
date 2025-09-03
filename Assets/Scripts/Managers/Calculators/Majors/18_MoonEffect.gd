extends MajorEffectBase
class_name MoonEffect

"""
=== The Moon ===
When drawn:
- If upright (not flipped): increments moons_drawn, sets charges for Moon, and sets card_state to POSITIVE.
- If reversed (flipped): sets stars_work_on_bad to true and sets card_state to NEGATIVE.
- Always triggers a major card animation.
In post-calc, Moon does not directly modify value, but its card_state and moons_drawn affect Star and other cards.
"""
var moons_drawn: int = 0

func apply(_card: Card, flipped: bool) -> int:
	if flipped:
		major_calc.get_major_effect(DataStructures.MAJOR_ID.STAR).works_on_negative = true
		card_state = DataStructures.CardState.NEGATIVE
	else:
		moons_drawn += 1
		card_state = DataStructures.CardState.POSITIVE
	
	return 0

func reset() -> void:
	moons_drawn = 0
	card_state = DataStructures.CardState.INACTIVE

func get_value(_additional_val: int = 0) -> int:
	return moons_drawn

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"moons_drawn": moons_drawn
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("moons_drawn"):
		moons_drawn = backup["moons_drawn"]