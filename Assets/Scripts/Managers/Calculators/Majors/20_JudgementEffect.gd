extends MajorEffectBase
class_name JudgementEffect

"""
=== Judgement ===
When drawn:
- If upright (not flipped): adds 1 charge to Judgement, sets card_state to POSITIVE if charges > 0, else NEGATIVE/INACTIVE.
- If reversed (flipped): removes 1 charge from Judgement, sets card_state to POSITIVE if charges > 0, else NEGATIVE/INACTIVE.
- Always triggers a major card animation.
In post-calc:
- If POSITIVE: multiplies value by (charges * major_judgement).
- If NEGATIVE: divides value by (charges * major_judgement), rounded down.
- Otherwise, returns value unchanged.
"""
var powers_of_ten: int = 0

func apply(_card: Card, flipped: bool) -> int:
	if flipped:
		powers_of_ten -= 1
	else:
		powers_of_ten += 1
	card_state = DataStructures.CardState.POSITIVE if powers_of_ten > 0 else DataStructures.CardState.NEGATIVE if powers_of_ten <= 0 else DataStructures.CardState.INACTIVE
	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func get_value(value: int = 0) -> int:
	var multiplier: float = powers_of_ten * game_state.stats.major_stats.judgement
	match card_state:
		DataStructures.CardState.POSITIVE:
			return roundi(value * multiplier)
		DataStructures.CardState.NEGATIVE:
			return int(float(value) / float(multiplier))
		_:
			return value

func reset() -> void:
	powers_of_ten = 0
	card_state = DataStructures.CardState.INACTIVE

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"powers_of_ten": powers_of_ten
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("powers_of_ten"):
		powers_of_ten = backup["powers_of_ten"]