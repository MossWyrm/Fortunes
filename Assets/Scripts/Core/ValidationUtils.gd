extends RefCounted
class_name ValidationUtils
## Simple validation utilities
##
## Provides basic validation methods with consistent error reporting.
## Keeps things simple and focused on the most common use cases.

#region Basic Validation
# Check if object is not null with context
static func is_valid(obj: Variant, context: String = "") -> bool:
	if obj == null:
		if not context.is_empty():
			push_error("ValidationUtils: Null object in %s" % context)
		return false
	return true

# Check if array has elements
static func has_elements(array: Array, context: String = "") -> bool:
	if array.is_empty():
		if not context.is_empty():
			push_warning("ValidationUtils: Empty array in %s" % context)
		return false
	return true

# Check if index is valid for array
static func is_valid_index(index: int, array_size: int, context: String = "") -> bool:
	if index < 0 or index >= array_size:
		if not context.is_empty():
			push_error("ValidationUtils: Index %d out of bounds for size %d in %s" % [index, array_size, context])
		return false
	return true
#endregion

#region Game State Helpers
# Quick check if EventBus is available
static func has_event_bus() -> bool:
	return GameManager.game_state != null and GameManager.game_state.event_bus != null

# Quick check if game state is available
static func has_game_state() -> bool:
	return GameManager.game_state != null

# Quick check if stats are available
static func has_stats() -> bool:
	return GameManager.game_state != null and GameManager.game_state.stats != null

# Quick check if deck manager is available
static func has_deck_manager() -> bool:
	return GameManager.game_state != null and GameManager.game_state.deck_manager != null

# Quick check if upgrade manager is available
static func has_upgrade_manager() -> bool:
	return GameManager.game_state != null and GameManager.game_state.upgrade_manager != null

# Check if card is valid
static func is_valid_card(card: Card, context: String = "") -> bool:
	if not is_valid(card, context):
		return false
	
	if card.card_title.is_empty():
		if not context.is_empty():
			push_warning("ValidationUtils: Card has empty title in %s" % context)
	
	return true
#endregion
