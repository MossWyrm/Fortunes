extends Node

## GameManager - Main game state and system coordinator
## Manages the core game architecture and provides system access

var game_state: GameState

func _ready():
	_initialize_game_systems()
	_setup_event_connections()

func _initialize_game_systems():
	game_state = GameState.new()
	
	if not ValidationUtils.validate_game_state(game_state):
		push_error("GameManager: Failed to initialize game state properly", DebugManager.DebugLevel.ERROR)
		return
	
	game_state.initialize_audio_manager(self)
	
	DebugManager.print_system_general("GameManager: Game systems initialized successfully")

	_on_game_initialized()

func _setup_event_connections():
	EventBus.game_loaded.connect(_on_game_loaded)

#region Event Handlers
func _on_game_initialized():
	DebugManager.print_system_general("GameManager: Game initialized")
	# Defer auto-load attempt to ensure AutoSave has finished its _ready()
	call_deferred("_attempt_auto_load")

func _on_game_loaded():
	DebugManager.print_system_general("GameManager: Game loaded")

# Attempt to auto-load save data if available
func _attempt_auto_load():
	var autosave_node = _find_autosave_node()
	if not autosave_node:
		DebugManager.print_system_general("GameManager: No AutoSaveNode found, starting fresh game", DebugManager.DebugLevel.WARNING)
		return
	
	if autosave_node.has_save_file():
		DebugManager.print_system_general("GameManager: Save file found, attempting to load...")
		if autosave_node.load_game():
			DebugManager.print_system_general("GameManager: Game loaded from save file")
		else:
			DebugManager.print_system_general("GameManager: Failed to load save file, starting fresh game", DebugManager.DebugLevel.ERROR)
	else:
		DebugManager.print_system_general("GameManager: No save file found, starting fresh game")

# Find AutoSaveNode in the scene tree
func _find_autosave_node() -> AutoSaveNode:
	# AutoSaveNode should be an autoload at /root/AutoSave
	var autosave_node = get_node_or_null("/root/AutoSave")
	
	if autosave_node and autosave_node is AutoSaveNode:
		return autosave_node as AutoSaveNode
	
	return null
#endregion

#region Public Interface
func get_game_state() -> GameState:
	if not ValidationUtils.validate_game_state(game_state):
		DebugManager.print_system_general("GameManager: Game state is invalid", DebugManager.DebugLevel.WARNING)
		return null
	return game_state

func is_game_ready() -> bool:
	return ValidationUtils.validate_game_state(game_state)
#endregion 