extends MajorEffectBase
class_name ChariotEffect

"""
=== The Chariot ===
When drawn, sets the Chariot card_state to POSITIVE (upright) or NEGATIVE (reversed).
Clears the chariot_tracker and triggers a major card animation.
The tracker and update logic are handled in MajorCalculator.
"""
var chariot_tracker: Array[int] = []

func apply(_card: Card, flipped: bool) -> int:
	var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	card_state = set_state
	chariot_tracker.clear()
	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func update(value: int) -> void:
	if value == 0 or card_state == DataStructures.CardState.INACTIVE:
		return
	if chariot_tracker.size() == 0 || abs(value) >= chariot_tracker[chariot_tracker.size()-1]:
		chariot_tracker.append(abs(value))
	else:
		trigger()

func trigger() -> void:
	var currency = 0
	match card_state:
		DataStructures.CardState.POSITIVE:
			currency = get_chariot_value()
		DataStructures.CardState.NEGATIVE:
			currency = -get_chariot_value()
	EventBus.emit_currency_updated(currency, DataStructures.CurrencyType.CLAIRVOYANCE)
	card_state = DataStructures.CardState.INACTIVE

func get_chariot_value() -> int:
	var output = chariot_tracker.reduce(func(accum,number): return accum * number, 0)
	return output

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	chariot_tracker.clear()

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"chariot_tracker": chariot_tracker.duplicate()
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("chariot_tracker"):
		chariot_tracker = backup["chariot_tracker"].duplicate()