extends RefCounted
class_name SaveManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Save configuration
var save_file_path: String = "user://save.json"
var autosave_frequency: float = 10.0
var autosave_timer: float = 0.0

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()

func _connect_events():
	event_bus.save_request.connect(save_game)

func save_game():
	var save_data = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"stats": game_state.stats.save(),
		"deck": game_state.deck_manager.save(),
		"upgrades": game_state.upgrade_manager.save()
	}
	
	_write_save_file(save_data)

func load_game() -> bool:
	var save_data = _read_save_file()
	
	if save_data.is_empty():
		return false
	
	# Validate save data
	if not _validate_save_data(save_data):
		print("Invalid save data detected")
		return false
	
	# Load data into game state
	game_state.stats.load(save_data.get("stats", {}))
	game_state.deck_manager.load(save_data.get("deck", {}))
	game_state.upgrade_manager.load(save_data.get("upgrades", {}))
	
	# Emit load complete event
	event_bus.emit_game_loaded()
	
	return true

func _write_save_file(data: Dictionary):
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if not file:
		print("Failed to open save file for writing: ", save_file_path)
		return
	
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	file.close()
	
	print("Game saved successfully")

func _read_save_file() -> Dictionary:
	if not FileAccess.file_exists(save_file_path):
		return {}
	
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if not file:
		print("Failed to open save file for reading: ", save_file_path)
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	
	if error != OK:
		print("Failed to parse save file JSON: ", json.get_error_message())
		return {}
	
	return json.data

func _validate_save_data(data: Dictionary) -> bool:
	# Check for required fields
	if not data.has("version"):
		return false
	
	if not data.has("stats"):
		return false
	
	if not data.has("deck"):
		return false
	
	if not data.has("upgrades"):
		return false
	
	# Check version compatibility
	var version = data.get("version", 0)
	if version > 1:
		print("Save file version ", version, " is newer than supported version 1")
		return false
	
	return true

func save_exists() -> bool:
	return FileAccess.file_exists(save_file_path)

func clear_save():
	if FileAccess.file_exists(save_file_path):
		DirAccess.open("user://").remove("save.json")
		print("Save file cleared")

func get_save_info() -> Dictionary:
	if not save_exists():
		return {}
	
	var save_data = _read_save_file()
	if save_data.is_empty():
		return {}
	
	return {
		"version": save_data.get("version", 0),
		"timestamp": save_data.get("timestamp", 0),
		"clairvoyance": save_data.get("stats", {}).get("clairvoyance", 0),
		"packs": save_data.get("stats", {}).get("packs", 0)
	}

func update(delta: float):
	# Handle autosave
	autosave_timer += delta
	if autosave_timer >= autosave_frequency:
		autosave_timer = 0.0
		save_game()

func reset(reset_type: DataStructures.GameLayer):
	if reset_type >= DataStructures.GameLayer.ALL:
		clear_save() 