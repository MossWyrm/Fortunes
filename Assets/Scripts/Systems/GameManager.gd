extends Node

## GameManager - Main game state and system coordinator
## Manages the core game architecture and provides system access

var game_state: GameState

func _ready():
	_initialize_game_systems()
	_setup_event_connections()

func _initialize_game_systems():
	# Initialize the main game state
	game_state = GameState.new()
	
	# Validate the initialization
	if not ValidationUtils.validate_game_state(game_state):
		push_error("GameManager: Failed to initialize game state properly")
		return
	
	print("GameManager: Game systems initialized successfully")

func _setup_event_connections():
	# Set up core event connections using SignalManager
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(
			game_state.event_bus.game_started, 
			_on_game_started, 
			"GameManager game_started"
		)
		
		SignalManager.safe_connect(
			game_state.event_bus.game_ended,
			_on_game_ended,
			"GameManager game_ended"
		)
		
		SignalManager.safe_connect(
			game_state.event_bus.save_requested,
			_on_save_requested,
			"GameManager save_requested"
		)

#region Event Handlers
func _on_game_started():
	print("GameManager: Game started")

func _on_game_ended():
	print("GameManager: Game ended")

func _on_save_requested():
	if ValidationUtils.has_save_manager():
		game_state.save_manager.save_game()
#endregion

#region Public Interface
func get_game_state() -> GameState:
	if not ValidationUtils.validate_game_state(game_state):
		push_warning("GameManager: Game stateYes is invalid")
		return null
	return game_state

func is_game_ready() -> bool:
	return ValidationUtils.validate_game_state(game_state)

# Compatibility methods for existing code
func get_deck() -> Array:
	if ValidationUtils.has_deck_manager():
		return game_state.deck_manager.get_deck()
	return []

func draw_card() -> Card:
	if ValidationUtils.has_deck_manager():
		return game_state.deck_manager.draw_card()
	return null

func peek_card() -> Card:
	if ValidationUtils.has_deck_manager():
		return game_state.deck_manager.peek_card()
	return null

func get_stats() -> GameStats:
	if ValidationUtils.has_game_state():
		return game_state.stats
	return null

func emit_card_drawn(card: Card):
	if ValidationUtils.has_event_bus():
		game_state.event_bus.emit_card_drawn(card)

func emit_currency_updated(amount: int, currency_type: DataStructures.CurrencyType):
	if ValidationUtils.has_event_bus():
		game_state.event_bus.emit_currency_updated(amount, currency_type)
#endregion 