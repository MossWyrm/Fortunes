extends MajorEffectBase
class_name SunEffect

"""
=== The Sun ===
When drawn:
- If upright (not flipped): adds major_sun_star (card 518) and major_sun_moon (card 519) to the deck.
- If reversed (flipped): removes all copies of card 518 and 519 from the deck.
- Provides exponential amplification to Star's formula
- Sets card_state to POSITIVE (upright) or NEGATIVE (flipped) in MajorCalculator.
- Always triggers a major card animation.
In post-calc, Sun does not directly modify value but amplifies Star's exponential.
"""

# Tracks Sun's contribution to the celestial exponential formula
var sun_amplifier: int = 0

func apply(_card: Card, flipped: bool) -> int:
	card_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	
	if flipped:
		# Solar Eclipse: Removes all celestials and resets amplification
		DebugManager.print_card_effects("[SunEffect] SOLAR ECLIPSE - Removing all celestials and resetting amplification", 
			  DebugManager.DebugLevel.INFO)
		game_state.deck_manager.remove_all_copies(518)  # Remove Stars
		game_state.deck_manager.remove_all_copies(519)  # Remove Moons
		game_state.deck_manager.remove_all_copies(520)  # Remove Suns
		sun_amplifier = 0  # Reset amplification to 0
		DebugManager.print_card_effects(str("[SunEffect] Eclipse complete - Sun amplifier reset to: ", sun_amplifier), 
			  DebugManager.DebugLevel.VERBOSE)
	else:
		# Solar Radiance: Adds celestials and amplifies exponential
		var stars_added = game_state.stats.major_stats.sun_star
		var moons_added = game_state.stats.major_stats.sun_moon
		
		DebugManager.print_card_effects(str("[SunEffect] SOLAR RADIANCE - Adding ", stars_added, " Stars and ", 
			  moons_added, " Moons"), DebugManager.DebugLevel.INFO)
		
		for i in stars_added:
			game_state.deck_manager.add_card_by_id(518)
		for i in moons_added:
			game_state.deck_manager.add_card_by_id(519)

		# Sun provides exponential amplification for Star formula
		sun_amplifier += 1
		DebugManager.print_card_effects(str("[SunEffect] Sun amplifier increased to: ", sun_amplifier, 
			  ", Contribution: ", get_sun_amplifier()), DebugManager.DebugLevel.VERBOSE)
	
	return 0

# Method for Star to access Sun's amplification
func get_sun_amplifier() -> int:
	if card_state == DataStructures.CardState.INACTIVE:
		return 0
	# Each sun drawn contributes (sun_amplifier * sun_exponent_stat) to the exponent
	return sun_amplifier * game_state.stats.major_stats.sun_exponent

func get_value(_additional_val: int = 0) -> int:
	# Return Sun's contribution to the exponential formula
	return sun_amplifier

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	sun_amplifier = 0

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"sun_amplifier": sun_amplifier
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("sun_amplifier"):
		sun_amplifier = backup["sun_amplifier"]