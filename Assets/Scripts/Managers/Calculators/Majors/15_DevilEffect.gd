extends MajorEffectBase
class_name DevilEffect

"""
=== The Devil ===
Creates a self-perpetuating cycle by adding Devil cards back to the deck.

Upright: You choose when to use skip charges strategically.
Gives you agency to skip bad cards, break combos, or even skip future Devils.

Reversed: You are forced to auto-skip the next X cards.
No choice in what gets skipped, but can break you out of bad streaks.

The Devil keeps re-adding itself to create ongoing cycles of bondage and liberation.
Strategic depth: Use charges to escape the very cycle that created them.
"""
var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
	# Set card_state based on flip
	if flipped:
		card_state = DataStructures.CardState.NEGATIVE
		DebugManager.print_card_effects("[DevilEffect] REVERSED DEVIL - Chains will force negative values", 
			  DebugManager.DebugLevel.INFO)
	else:
		card_state = DataStructures.CardState.POSITIVE
		DebugManager.print_card_effects("[DevilEffect] UPRIGHT DEVIL - Chains will force positive values", 
			  DebugManager.DebugLevel.INFO)

	# Add charges for Devil (from stats)
	charges = game_state.stats.major_stats.devil
	DebugManager.print_card_effects(str("[DevilEffect] Devil charges set to: ", charges), 
		  DebugManager.DebugLevel.VERBOSE)

	# Add Devil card to deck if deck size >= 3
	var deck_size = game_state.deck_manager.active_deck.size()
	var threshold = game_state.stats.major_stats.devil
	if deck_size >= threshold:
		game_state.deck_manager.add_card_by_id(516)
		DebugManager.print_card_effects(str("[DevilEffect] TEMPTATION - Added Devil card 516 to deck (size ", 
			  deck_size, " >= ", threshold, ")"), DebugManager.DebugLevel.INFO)
	else:
		DebugManager.print_card_effects(str("[DevilEffect] No temptation - deck size ", deck_size, 
			  " < threshold ", threshold), DebugManager.DebugLevel.VERBOSE)

	
	return 0

func forced() -> bool:
	return card_state == DataStructures.CardState.NEGATIVE

func is_active() -> bool:
	return charges > 0

func use():
	var old_charges = charges
	charges -= 1
	DebugManager.print_card_effects(str("[DevilEffect] BREAKING CHAINS - Charges: ", old_charges, 
		  " → ", charges), DebugManager.DebugLevel.INFO)
	
	if charges <= 0:
		card_state = DataStructures.CardState.INACTIVE
		DebugManager.print_card_effects("[DevilEffect] FREEDOM - Devil chains broken, effect deactivated", 
			  DebugManager.DebugLevel.INFO)

func get_value(_additional_val: int = 0) -> int:
	# Return charges for display purposes
	return charges

func reset():
	card_state = DataStructures.CardState.INACTIVE
	charges = 0

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"charges": charges
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("charges"):
		charges = backup["charges"]