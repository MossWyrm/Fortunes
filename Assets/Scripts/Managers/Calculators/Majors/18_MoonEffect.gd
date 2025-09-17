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
		# Dark Moon: Decreases exponential power and makes Stars work on negatives
		var old_moons = moons_drawn
		moons_drawn -= 1
		moons_drawn = max(0, moons_drawn)  # Don't go below 0
		major_calc.get_major_effect(DataStructures.MAJOR_ID.STAR).works_on_negative = true
		card_state = DataStructures.CardState.NEGATIVE
		
		DebugManager.print_card_effects(str("[MoonEffect] DARK MOON - Moons drawn: ", old_moons, " → ", 
			  moons_drawn, ", Stars now work on negatives"), DebugManager.DebugLevel.INFO)
		DebugManager.print_card_effects(str("[MoonEffect] Moon exponent contribution: ", 
			  get_moon_exponent_contribution()), DebugManager.DebugLevel.VERBOSE)
	else:
		# Bright Moon: Increases exponential power and adds Stars
		moons_drawn += 1
		card_state = DataStructures.CardState.POSITIVE
		
		# Moon adds Stars to deck based on upgradeable moon stat
		var stars_to_add = game_state.stats.major_stats.moon
		DebugManager.print_card_effects(str("[MoonEffect] BRIGHT MOON - Moons drawn: ", moons_drawn, 
			  ", Adding ", stars_to_add, " Stars to deck"), DebugManager.DebugLevel.INFO)
		
		for i in range(stars_to_add):
			game_state.deck_manager.add_card_by_id(518)  # Add Star cards
			
		DebugManager.print_card_effects(str("[MoonEffect] Moon exponent contribution: ", 
			  get_moon_exponent_contribution()), DebugManager.DebugLevel.VERBOSE)
	
	return 0

func reset() -> void:
	moons_drawn = 0
	card_state = DataStructures.CardState.INACTIVE

func get_value(_additional_val: int = 0) -> int:
	# Return Moon's contribution to the exponential formula
	return moons_drawn

# Method for other effects to access Moon's exponential contribution
func get_moon_exponent_contribution() -> int:
	if card_state == DataStructures.CardState.INACTIVE:
		return 0
	# Each moon drawn contributes (moons_drawn * moon_exponent_stat) to the exponent
	return moons_drawn * game_state.stats.major_stats.moon_exponent

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