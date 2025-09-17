extends MajorEffectBase
class_name TowerEffect

"""
=== The Tower ===
When drawn, if not already active, set card_state to POSITIVE (upright) or NEGATIVE (reversed) and add card 517 to the deck.
If already active, toggle the card_state and increase chaos level.
Each Tower drawn increases the multiplier/divisor, creating escalating chaos that resets on shuffle.
In post-calc: 
  - If POSITIVE, multiply value by (major_tower stat + tower_count).
  - If NEGATIVE, divide value by (major_tower stat + tower_count) (rounded down).
  - Otherwise, return value unchanged.
Always triggers a major card animation.
"""

# Tracks how many Towers have been drawn since last shuffle - escalating chaos
var tower_count: int = 0
func apply(_card: Card, flipped: bool) -> int:
	# Increment tower count - escalating chaos with each Tower drawn
	var old_count = tower_count
	tower_count += 1
	
	# If already active, toggle card_state
	if card_state != DataStructures.CardState.INACTIVE:
		var old_state = card_state
		if card_state == DataStructures.CardState.NEGATIVE:
			card_state = DataStructures.CardState.POSITIVE
		else:
			card_state = DataStructures.CardState.NEGATIVE
		DebugManager.print_card_effects(str("[TowerEffect] ESCALATING CHAOS - Tower count: ", old_count, 
			  " → ", tower_count, ", State: ", old_state, " → ", card_state), DebugManager.DebugLevel.INFO)
	else:
		card_state = DataStructures.CardState.POSITIVE if !flipped else DataStructures.CardState.NEGATIVE
		game_state.deck_manager.add_card_by_id(517)
		DebugManager.print_card_effects(str("[TowerEffect] TOWER ACTIVATED - Initial state: ", card_state, 
			  ", Added card 517 to deck, Tower count: ", tower_count), DebugManager.DebugLevel.INFO)
	
	var escalating_multiplier = game_state.stats.major_stats.tower * tower_count
	DebugManager.print_card_effects(str("[TowerEffect] Escalating multiplier: ", escalating_multiplier, 
		  " (", game_state.stats.major_stats.tower, " × ", tower_count, ")"), DebugManager.DebugLevel.VERBOSE)
	
	return 0

func get_value(_value: int = 0) -> int:
	# Return the amount of towers drawn for display purposes
	return tower_count

func apply_tower_to_card(value: int) -> int:
	var escalating_multiplier = game_state.stats.major_stats.tower * tower_count
	var output: int = 0
	match card_state:
		DataStructures.CardState.POSITIVE:
			output = value * escalating_multiplier
			DebugManager.print_card_effects(str("[TowerEffect] CHAOS AMPLIFICATION: ", value, " × ", 
				  escalating_multiplier, " = ", output), DebugManager.DebugLevel.INFO)
		DataStructures.CardState.NEGATIVE:
			# Ensure we don't divide by zero
			if escalating_multiplier > 0:
				output = int(float(value) / float(escalating_multiplier))
				DebugManager.print_card_effects(str("[TowerEffect] CHAOS REDUCTION: ", value, " ÷ ", 
					  escalating_multiplier, " = ", output), DebugManager.DebugLevel.INFO)
			else:
				output = value
				DebugManager.print_card_effects(str("[TowerEffect] No chaos effect (multiplier 0): ", value), 
					  DebugManager.DebugLevel.VERBOSE)
		_:
			output = value
			DebugManager.print_card_effects(str("[TowerEffect] Inactive - no chaos effect: ", value), 
				  DebugManager.DebugLevel.VERBOSE)
			output = value
	return output

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	tower_count = 0