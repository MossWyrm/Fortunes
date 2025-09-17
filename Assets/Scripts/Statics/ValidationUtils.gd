extends RefCounted
class_name ValidationUtils

## Simple validation utilities

static func is_valid(obj: Variant, context: String = "") -> bool:
	if obj == null:
		if not context.is_empty():
			DebugManager.print_system_general("ValidationUtils: Null object in %s" % context, DebugManager.DebugLevel.ERROR)
		return false
	return true


#region Game State Helpers
static func has_game_state() -> bool:
	return GameManager != null and GameManager.game_state != null

static func has_stats() -> bool:
	return GameManager.game_state != null and GameManager.game_state.stats != null

static func has_deck_manager() -> bool:
	return GameManager.game_state != null and GameManager.game_state.deck_manager != null

static func has_upgrade_manager() -> bool:
	return GameManager.game_state != null and GameManager.game_state.upgrade_manager != null

static func has_card_calculator() -> bool:
	return GameManager.game_state != null and GameManager.game_state.card_calculator != null

static func validate_game_state(game_state: GameState) -> bool:
	if not is_valid(game_state, "validate_game_state"):
		return false
		
	if not is_valid(game_state.stats, "game_state.stats"):
		return false
	
	return true
#endregion
