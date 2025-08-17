extends RefCounted
class_name MajorEffectBase

# Base class for all Major Arcana effects
var major_calc: MajorCalculator
var game_state: GameState
var state: DataStructures.CardState = DataStructures.CardState.INACTIVE

func _init(state: GameState) -> void:
	major_calc = state.major_calculator
	self.game_state = state


# Called when the card is drawn. Override in subclasses for card-specific logic.
func apply(_card: Card, _flipped: bool) -> int:
	return 0


# Called to shuffle or reset the effect. Used for deck shuffling or effect resets.
func shuffle(safely: bool = false) -> void:
	print("shuffle not implemented for %s" % self.name)
	pass


# Called to update the internal state or mechanisms of the effect.
func update(value: int) -> void:
	print("update not implemented for %s" % self.name)
	pass


# Called to retrieve a value from the effect (e.g., for scoring or display).
func get_value(_additional_val: int = 0) -> int:
	print("get_value not implemented for %s" % self.name)
	return 0


# Called to trigger the effect outside of drawing (e.g., by another card or event).
func trigger() -> void:
	print("trigger not implemented for %s" % self.name)
	pass


# Returns true if the effect is currently active.
func active() -> bool:
	return state != DataStructures.CardState.INACTIVE


# Resets the effect to its default state.
func reset() -> void:
	state = DataStructures.CardState.INACTIVE

# Returns a dictionary representing the effect's state for backup
func get_state_backup() -> Dictionary:
	return {"state": state}

# Restores the effect's state from a backup dictionary
func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("state"):
		state = backup["state"]