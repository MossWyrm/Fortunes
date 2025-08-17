extends MajorEffectBase
class_name ChariotEffect

"""
=== The Chariot ===
When drawn, sets the Chariot state to POSITIVE (upright) or NEGATIVE (reversed).
Clears the chariot_tracker and triggers a major card animation.
The tracker and update logic are handled in MajorCalculator.
"""
var chariot_tracker: Array[int] = []

func apply(_card: Card, flipped: bool) -> int:
	var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	state = set_state
	chariot_tracker.clear()
	game_state.event_bus.emit_major_card_animation_requested(flipped)
	return 0

func update(value: int) -> void:
	if value == 0 or state == DataStructures.CardState.INACTIVE:
		return
	if chariot_tracker.size() == 0 || abs(value) >= chariot_tracker[chariot_tracker.size()-1]:
		chariot_tracker.append(abs(value))
	else:
		trigger()

func trigger() -> void:
	var currency = 0
	match state:
		DataStructures.CardState.POSITIVE:
			currency = get_chariot_value()
		DataStructures.CardState.NEGATIVE:
			currency = -get_chariot_value()
	game_state.event_bus.emit_currency_updated(currency, DataStructures.CurrencyType.CLAIRVOYANCE)
	state = DataStructures.CardState.INACTIVE

func get_chariot_value() -> int:
	var output = chariot_tracker.reduce(func(accum,number): return accum * number, 0)
	return output

func reset() -> void:
	state = DataStructures.CardState.INACTIVE
	chariot_tracker.clear()

func get_state_backup() -> Dictionary:
	return {
		"state": state,
		"chariot_tracker": chariot_tracker.duplicate()
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("state"):
		state = backup["state"]
	if backup.has("chariot_tracker"):
		chariot_tracker = backup["chariot_tracker"].duplicate()