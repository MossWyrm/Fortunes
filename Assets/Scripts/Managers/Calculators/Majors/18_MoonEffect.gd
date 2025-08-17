extends MajorEffectBase
class_name MoonEffect

"""
=== The Moon ===
When drawn:
- If upright (not flipped): increments moons_drawn, sets charges for Moon, and sets state to POSITIVE.
- If reversed (flipped): sets stars_work_on_bad to true and sets state to NEGATIVE.
- Always triggers a major card animation.
In post-calc, Moon does not directly modify value, but its state and moons_drawn affect Star and other cards.
"""
var moons_drawn: int = 0

func apply(card: Card, flipped: bool) -> int:
	if flipped:
		major_calc.get_major_effect(DataStructures.MAJOR_ID.STAR).works_on_negative = true
		state = DataStructures.CardState.NEGATIVE
	else:
		moons_drawn += 1
		state = DataStructures.CardState.POSITIVE
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0

func reset() -> void:
	moons_drawn = 0
	state = DataStructures.CardState.INACTIVE

func get_state_backup() -> Dictionary:
	return {
		"state": state,
		"moons_drawn": moons_drawn
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("state"):
		state = backup["state"]
	if backup.has("moons_drawn"):
		moons_drawn = backup["moons_drawn"]