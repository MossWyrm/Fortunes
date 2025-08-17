extends RefCounted
class_name SaveWriter
## Save game file management utility
##
## Handles reading, writing, and managing save game files.
## Provides JSON-based persistence for game data.

#region Constants
const SAVE_GAME_PATH: String = "user://save.json"
const SAVE_VERSION: int = 1
#endregion

#region Save File Operations
# Check if a save file exists
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)

# Write game data to save file
func write_savegame(data: Dictionary) -> bool:
	print("SaveWriter: Attempting to save game data")
	
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if file == null:
		var error_code = FileAccess.get_open_error()
		push_error(DescriptionFormatter.format_error_message("SaveWriter: Could not open save file for writing. Path: %s, Error" % SAVE_GAME_PATH, str(error_code)))
		return false
	
	# Add version info to save data
	var save_data := data.duplicate()
	save_data["version"] = SAVE_VERSION
	
	var json_string := JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	
	print("SaveWriter: Save completed successfully")
	return true

# Load game data from save file
func load_savegame() -> Dictionary:
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if file == null:
		var error_code = FileAccess.get_open_error()
		push_error("SaveWriter: Could not open save file for reading. Path: %s, Error: %s" % [SAVE_GAME_PATH, error_code])
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	return _parse_save_data(json_string)

# Parse JSON save data with error handling
func _parse_save_data(json_string: String) -> Dictionary:
	var json := JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("SaveWriter: JSON parse error - %s at line %s in: %s" % [
			json.get_error_message(), 
			json.get_error_line(), 
			json_string.substr(0, 100) + "..."
		])
		return {}
	
	var data: Dictionary = json.data
	
	# Version compatibility check
	if data.has("version") and data["version"] != SAVE_VERSION:
		push_warning("SaveWriter: Save file version mismatch. Expected: %s, Found: %s" % [SAVE_VERSION, data["version"]])
	
	return data

# Delete the save file
func clear_save() -> bool:
	var dir := DirAccess.open("user://")
	if dir == null:
		push_error("SaveWriter: Could not access user directory for save deletion")
		return false
	
	if dir.file_exists("save.json"):
		var error = dir.remove("save.json")
		if error == OK:
			print("SaveWriter: Save file deleted successfully")
			return true
		else:
			push_error("SaveWriter: Failed to delete save file. Error: %s" % error)
			return false
	else:
		print("SaveWriter: No save file found to delete")
		return true
#endregion
	
	