extends MajorEffectBase
class_name DevilEffect

"""
=== The Devil ===
When drawn, sets card_state to POSITIVE (upright) or NEGATIVE (reversed).
If upright, player is forced to skip a choice (devil_forced). If reversed, player is given a choice to skip (devil_active).
Always triggers a major card animation.
"""
var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
	# Set card_state based on flip
	if flipped:
		card_state = DataStructures.CardState.NEGATIVE
	else:
		card_state = DataStructures.CardState.POSITIVE

	# Add charges for Devil (from stats)
	charges = game_state.stats.major_stats.devil

	# Add Devil card to deck if deck size >= 3
	if game_state.deck_manager.active_deck.size() >= game_state.stats.major_stats.devil:
		game_state.deck_manager.add_card(516)

	EventBus.emit_major_card_animation_requested(flipped)
	return 0

func forced() -> bool:
	return card_state == DataStructures.CardState.NEGATIVE

func use():
	charges -= 1
	if charges <= 0:
		card_state = DataStructures.CardState.INACTIVE

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