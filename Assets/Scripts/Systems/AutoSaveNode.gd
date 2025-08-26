extends Node
class_name AutoSaveNode
## Dedicated autosave system
##
## A standalone Node that handles automatic saving at regular intervals.
## Should be added to the scene tree and configured with game state reference.

#region Configuration
@export var autosave_interval: float = 30.0  # Save every 30 seconds
@export var enable_autosave: bool = true
#endregion

#region Dependencies
var game_manager: GameManager
var save_writer: SaveWriter
var autosave_timer: Timer
#endregion

#region Initialization
func _ready():
	_setup_save_writer()
	_setup_autosave_timer()
	_connect_to_game_manager()

func _setup_save_writer():
	save_writer = SaveWriter.new()

func _setup_autosave_timer():
	autosave_timer = Timer.new()
	autosave_timer.wait_time = autosave_interval
	autosave_timer.timeout.connect(_on_autosave_timeout)
	autosave_timer.autostart = enable_autosave
	add_child(autosave_timer)

func _connect_to_game_manager():
	# Find GameManager in scene or wait for it
	game_manager = get_node("/root/GameManager") if get_node_or_null("/root/GameManager") else null
	
	if game_manager and enable_autosave:
		autosave_timer.start()
		print("AutoSaveNode: Connected to GameManager, autosave started")
	else:
		print("AutoSaveNode: GameManager not found, autosave disabled")
#endregion

#region Save Operations
func _on_autosave_timeout():
	perform_autosave()

func perform_autosave():
	if not game_manager or not game_manager.is_game_ready():
		print("AutoSaveNode: Game not ready for save")
		return
	
	var game_state = game_manager.get_game_state()
	if not game_state:
		print("AutoSaveNode: No game state available")
		return
	
	# Collect save data from all systems
	var save_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"version": 1,
		"stats": game_state.stats.save() if game_state.stats else {},
		"deck": game_state.deck_manager.save() if game_state.deck_manager else {},
		"upgrades": game_state.upgrade_manager.save() if game_state.upgrade_manager else {}
	}
	
	# Write to file
	if save_writer.write_savegame(save_data):
		print("AutoSaveNode: Game saved successfully")
		_emit_save_completed()
	else:
		print("AutoSaveNode: Save failed")

# Load game data from file
func load_game() -> bool:
	if not save_writer.save_exists():
		print("AutoSaveNode: No save file found")
		return false
	
	var save_data = save_writer.load_savegame()
	if not save_data:
		print("AutoSaveNode: Failed to load save data")
		return false
	
	if not game_manager or not game_manager.is_game_ready():
		print("AutoSaveNode: Game not ready for load")
		return false
	
	var game_state = game_manager.get_game_state()
	if not game_state:
		print("AutoSaveNode: No game state available for loading")
		return false
	
	# Load data into all systems
	if save_data.has("stats") and game_state.stats:
		print("AutoSaveNode: Loading stats data...")
		game_state.stats.load(save_data["stats"])
		print("AutoSaveNode: Stats loaded, clairvoyance:", game_state.stats.clairvoyance)
	
	if save_data.has("deck") and game_state.deck_manager:
		print("AutoSaveNode: Loading deck data...")
		game_state.deck_manager.load(save_data["deck"])
	
	if save_data.has("upgrades") and game_state.upgrade_manager:
		print("AutoSaveNode: Loading upgrades data...")
		game_state.upgrade_manager.load(save_data["upgrades"])
	
	print("AutoSaveNode: Game loaded successfully")
	_emit_game_loaded()
	return true

func _emit_save_completed():
	# Emit through GameManager's event bus if available
	if game_manager and game_manager.is_game_ready():
		var game_state = game_manager.get_game_state()
		if game_state and EventBus:
			EventBus.emit_save_completed()

func _emit_game_loaded():
	EventBus.emit_game_loaded()

# Manual save trigger
func save_now():
	perform_autosave()

# Check if save file exists
func has_save_file() -> bool:
	if not save_writer:
		push_warning("AutoSaveNode: save_writer not initialized yet")
		return false
	return save_writer.save_exists()

# Enable/disable autosave
func set_autosave_enabled(enabled: bool):
	enable_autosave = enabled
	if autosave_timer:
		if enabled:
			autosave_timer.start()
		else:
			autosave_timer.stop()
#endregion
