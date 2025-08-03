class_name MigrationLayer
extends RefCounted

# Migration layer to bridge old global singleton system with new architecture
# This allows for gradual migration without breaking existing functionality

static var _instance: MigrationLayer
static var _game_state: RefCounted

static func get_instance() -> MigrationLayer:
	if not _instance:
		_instance = MigrationLayer.new()
	return _instance

static func initialize_game_state() -> RefCounted:
	if not _game_state:
		# We'll initialize this when the GameState class is properly loaded
		_game_state = null
	return _game_state

# Legacy compatibility methods - these maintain the old GM interface
static func get_deck() -> Array:
	var game_state = get_instance()._game_state
	if not game_state:
		return []
	return game_state.deck_manager.get_deck()

static func draw_card() -> RefCounted:
	var game_state = get_instance()._game_state
	if not game_state:
		return null
	return game_state.deck_manager.draw_card()

static func peek_card() -> RefCounted:
	var game_state = get_instance()._game_state
	if not game_state:
		return null
	return game_state.deck_manager.peek_card()

static func get_stats() -> RefCounted:
	var game_state = get_instance()._game_state
	if not game_state:
		return null
	return game_state.game_stats

# Legacy event emission
static func emit_card_drawn(card: RefCounted):
	var game_state = get_instance()._game_state
	if not game_state:
		return
	game_state.event_bus.emit_card_drawn(card)

static func emit_currency_updated(currency_type: int, amount: int):
	var game_state = get_instance()._game_state
	if not game_state:
		return
	game_state.event_bus.emit_currency_updated(currency_type, amount)

# Migration helper methods
static func migrate_legacy_stats() -> RefCounted:
	# This will be implemented when we have access to the scene tree
	# For now, return null to indicate migration not ready
	return null

static func migrate_legacy_deck() -> Array:
	# This will be implemented when we have access to the scene tree
	# For now, return empty array to indicate migration not ready
	return [] 