extends MajorEffectBase
class_name ChariotEffect

"""
=== The Chariot ===
When drawn, sets the Chariot card_state to POSITIVE (upright) or NEGATIVE (reversed).
Clears the chariot_tracker and begins tracking final card values for chaining.

Chains cards together when each card's final ABSOLUTE value (after all effects) is greater than 
or equal to the previous card's final ABSOLUTE value. When the chain breaks, provides a payout 
equal to the sum of all chained final values. Payout is positive if upright, negative 
if reversed. Becomes dormant after payout until Chariot is drawn again.
"""
var chariot_tracker: Array[int] = []

func apply(_card: Card, flipped: bool) -> int:
	var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	card_state = set_state
	chariot_tracker.clear()
	
	DebugManager.print_card_effects(str("[ChariotEffect] THE CHARIOT - ", 
	      "Beginning reversed chain" if flipped else "Beginning upright chain", 
	      ", Chain tracking started"), DebugManager.DebugLevel.INFO)
	
	return 0

func update(value: int) -> void:
	if value == 0 or card_state == DataStructures.CardState.INACTIVE:
		return
	if chariot_tracker.size() == 0 || abs(value) >= chariot_tracker[chariot_tracker.size()-1]:
		chariot_tracker.append(abs(value))
		DebugManager.print_card_effects(str("[ChariotEffect] Chain continues: added ", abs(value), 
		      " (chain length: ", chariot_tracker.size(), ")"), DebugManager.DebugLevel.VERBOSE)
	else:
		DebugManager.print_card_effects(str("[ChariotEffect] Chain broken: ", abs(value), 
		      " < ", chariot_tracker[chariot_tracker.size()-1], ", triggering payout"), DebugManager.DebugLevel.INFO)
		trigger()

func trigger() -> void:
	var currency = 0
	match card_state:
		DataStructures.CardState.POSITIVE:
			currency = get_value()
			DebugManager.print_card_effects(str("[ChariotEffect] Upright chain payout: +", currency, 
			      " clairvoyance"), DebugManager.DebugLevel.INFO)
		DataStructures.CardState.NEGATIVE:
			currency = -get_value()
			DebugManager.print_card_effects(str("[ChariotEffect] Reversed chain payout: ", currency, 
			      " clairvoyance"), DebugManager.DebugLevel.INFO)
	
	DebugManager.print_card_effects(str("[ChariotEffect] Chain values: ", chariot_tracker, 
	      ", Total: ", get_value()), DebugManager.DebugLevel.VERBOSE)
	
	EventBus.emit_currency_updated(currency, DataStructures.CurrencyType.CLAIRVOYANCE)
	card_state = DataStructures.CardState.INACTIVE

func get_value(_additional_val: int = 0) -> int:
	if chariot_tracker.size() == 0:
		return 0
	# Sum all the chained values instead of multiplying them
	var output = chariot_tracker.reduce(func(accum, number): return accum + number, 0)
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