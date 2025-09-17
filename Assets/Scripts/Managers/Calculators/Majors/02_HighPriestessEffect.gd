extends MajorEffectBase
class_name HighPriestessEffect

"""
=== The High Priestess (Transformation Effect) ===
When active, transforms drawn cards through a ghostly ripple animation.
The player chooses from 3 random cards to replace the original with.

Upright (Positive): Player chooses which card to transform into after seeing the ghostly preview.
Reversed (Negative): A random card is forced upon the player, shown through immediate transformation.

Uses charges based on MajorStats.high_priestess. Each use consumes one charge.
Triggers special ghost animation with ripple transformation effects.
"""
var charges: int = 0

func _init(state: GameState) -> void:
	super._init(state)

func apply(_card: Card, flipped: bool) -> int:
	card_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
	charges = game_state.stats.major_stats.high_priestess

	DebugManager.print_card_effects(str("[HighPriestessEffect] HIGH PRIESTESS AWAKENS - ", 
		  "Forced transformation" if flipped else "Chosen transformation", 
		  ", Charges: ", charges), DebugManager.DebugLevel.INFO)

	return 0

func get_value(_additional_val: int = 0) -> int:
	return charges

func use() -> Array[Card]:
	var cards: Array[Card] = []
	DebugManager.print_card_effects("[HighPriestessEffect] MYSTICAL TRANSFORMATION - Generating options", 
		  DebugManager.DebugLevel.INFO)
	
	while cards.size() < 3:
		var card = game_state.deck_manager.active_deck._get_random_card(false)
		if card not in cards:
			cards.append(card)
			DebugManager.print_card_effects(str("[HighPriestessEffect] Option ", cards.size(), ": ", 
				  card.value, " of ", card.suit), DebugManager.DebugLevel.VERBOSE)
	
	consume()
	DebugManager.print_card_effects(str("[HighPriestessEffect] Transformation options ready, charges remaining: ", 
		  charges), DebugManager.DebugLevel.VERBOSE)
	return cards

func reset() -> void:
	charges = 0
	card_state = DataStructures.CardState.INACTIVE

func consume() -> void:
	charges -= 1
	if charges <= 0:
		card_state = DataStructures.CardState.INACTIVE

func forced() -> bool:
	return card_state == DataStructures.CardState.NEGATIVE