extends MajorEffectBase
class_name EmperorEffect

"""
=== The Emperor ===
When drawn, sets the Emperor card_state to POSITIVE (upright) or NEGATIVE (reversed).
The Emperor increases the value of all cards by MajorStats.emperor (positive or negative based on card_state).
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
	# Set the Emperor card_state using the generic major card_state system and shared enum
	var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	card_state = set_state
	
	var emperor_value = game_state.stats.major_stats.emperor
	DebugManager.print_card_effects(str("[EmperorEffect] THE EMPEROR COMMANDS - ", 
		  "Tyrannical rule (-" if flipped else "Benevolent rule (+", emperor_value, 
		  " to all cards)"), DebugManager.DebugLevel.INFO)
	
	return 0

# Returns the Emperor's effect value based on card_state.
func get_value(_additional_val: int = 0) -> int:
	match card_state:
		DataStructures.CardState.POSITIVE:
			return game_state.stats.major_stats.emperor
		DataStructures.CardState.NEGATIVE:
			return -game_state.stats.major_stats.emperor
		_:
			return 0

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE