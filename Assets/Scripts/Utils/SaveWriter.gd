extends RefCounted
class_name SaveWriter
## Save game file management utility
##
## Handles reading, writing, and managing save game files.
## Provides JSON-based persistence for game data.

#region Constants
const SAVE_GAME_PATH: String = "user://save.json"
const CURRENT_SAVE_VERSION: int = 2  # Increment this when making breaking changes
const MIN_SUPPORTED_VERSION: int = 2  # Oldest version we can migrate from
#endregion

#region Save File Operations
# Check if a save file exists
func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)

# Write game data to save file
func write_savegame(data: Dictionary) -> bool:
	DebugManager.print_file_operations("SaveWriter: Attempting to save game data", DebugManager.DebugLevel.INFO)
	
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if file == null:
		var error_code = FileAccess.get_open_error()
		DebugManager.print_file_operations("SaveWriter: Could not open save file for writing. Path: %s, Error: %s" % [SAVE_GAME_PATH, str(error_code)], DebugManager.DebugLevel.ERROR)
		return false
	
	# Add version info to save data
	var save_data := data.duplicate()
	save_data["version"] = CURRENT_SAVE_VERSION
	save_data["created_timestamp"] = Time.get_unix_time_from_system()
	
	var json_string := JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()
	
	DebugManager.print_file_operations("SaveWriter: Save completed successfully", DebugManager.DebugLevel.INFO)
	return true

# Load game data from save file
func load_savegame() -> Dictionary:
	var file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if file == null:
		var error_code = FileAccess.get_open_error()
		DebugManager.print_file_operations("SaveWriter: Could not open save file for reading. Path: %s, Error: %s" % [SAVE_GAME_PATH, error_code], DebugManager.DebugLevel.ERROR)
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	return _parse_save_data(json_string)

# Parse JSON save data with error handling
func _parse_save_data(json_string: String) -> Dictionary:
	var json := JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		DebugManager.print_file_operations("SaveWriter: JSON parse error - %s at line %s in: %s" % [
			json.get_error_message(), 
			json.get_error_line(), 
			json_string.substr(0, 100) + "..."
		], DebugManager.DebugLevel.ERROR)
		return {}
	
	var data: Dictionary = json.data
	
	# Handle version compatibility and migration
	return _handle_save_version_compatibility(data)

# Delete the save file
func clear_save() -> bool:
	var dir := DirAccess.open("user://")
	if dir == null:
		DebugManager.print_file_operations("SaveWriter: Could not access user directory for save deletion", DebugManager.DebugLevel.ERROR)
		return false
	
	if dir.file_exists("save.json"):
		var error = dir.remove("save.json")
		if error == OK:
			DebugManager.print_file_operations("SaveWriter: Save file deleted successfully", DebugManager.DebugLevel.INFO)
			return true
		else:
			DebugManager.print_file_operations("SaveWriter: Failed to delete save file. Error: %s" % error, DebugManager.DebugLevel.ERROR)
			return false
	else:
		DebugManager.print_file_operations("SaveWriter: No save file found to delete", DebugManager.DebugLevel.INFO)
		return true

#region Version Compatibility & Migration
# Handle save version compatibility and perform migrations
func _handle_save_version_compatibility(data: Dictionary) -> Dictionary:
	var save_version = data.get("version", 1)  # Default to version 1 for old saves
	
	DebugManager.print_file_operations("SaveWriter: Loading save data version %d (current: %d)" % [save_version, CURRENT_SAVE_VERSION])
	
	# Check if version is too old to migrate
	if save_version < MIN_SUPPORTED_VERSION:
		DebugManager.print_file_operations("SaveWriter: Save version %d is too old (minimum supported: %d). Save data will be reset." % [save_version, MIN_SUPPORTED_VERSION], DebugManager.DebugLevel.WARNING)
		return {}  # Return empty data to trigger fresh start
	
	# Check if save is from the future
	if save_version > CURRENT_SAVE_VERSION:
		DebugManager.print_file_operations("SaveWriter: Save version %d is newer than current %d. This may cause compatibility issues." % [save_version, CURRENT_SAVE_VERSION], DebugManager.DebugLevel.WARNING)
		return data  # Use as-is, hope for the best
	
	# Perform migration if needed
	if save_version < CURRENT_SAVE_VERSION:
		DebugManager.print_file_operations("SaveWriter: Migrating save data from version %d to %d" % [save_version, CURRENT_SAVE_VERSION])
		data = _migrate_save_data(data, save_version)
		data["version"] = CURRENT_SAVE_VERSION
		data["migrated_from"] = save_version
		data["migration_timestamp"] = Time.get_unix_time_from_system()
	
	return data

# Migrate save data from older versions to current version
func _migrate_save_data(data: Dictionary, from_version: int) -> Dictionary:
	var migrated_data = data.duplicate(true)
	
	# Migration chain - each version builds on the previous
	for version in range(from_version + 1, CURRENT_SAVE_VERSION + 1):
		match version:
			2:
				migrated_data = _migrate_to_version_2(migrated_data)
			# Add future migrations here:
			# 3:
			#     migrated_data = _migrate_to_version_3(migrated_data)
			# 4:
			#     migrated_data = _migrate_to_version_4(migrated_data)
		
		DebugManager.print_file_operations("SaveWriter: Migrated to version %d" % version)
	
	return migrated_data

# Migration to version 2 - add any structural changes here
func _migrate_to_version_2(data: Dictionary) -> Dictionary:
	var migrated = data.duplicate(true)
	
	# Example migrations for version 2:
	# - Add new fields with defaults
	# - Restructure existing data
	# - Convert old format to new format
	
	# Add metadata if missing
	if not migrated.has("metadata"):
		migrated["metadata"] = {
			"game_version": "1.0.0",
			"platform": OS.get_name()
		}
	
	# Ensure all required sections exist
	if not migrated.has("stats"):
		migrated["stats"] = {}
	if not migrated.has("deck"):
		migrated["deck"] = {}
	if not migrated.has("upgrades"):
		migrated["upgrades"] = {}
	
	return migrated

# Validate save data structure
func _validate_save_structure(data: Dictionary) -> bool:
	# Check for required fields
	var required_fields = ["version", "stats", "deck", "upgrades"]
	for field in required_fields:
		if not data.has(field):
			DebugManager.print_file_operations("SaveWriter: Missing required field: %s" % field, DebugManager.DebugLevel.ERROR)
			return false
	
	return true

# Create backup of save before migration
func _create_backup_save(original_data: Dictionary, from_version: int) -> bool:
	var backup_path = "user://save_backup_v%d_%d.json" % [from_version, Time.get_unix_time_from_system()]
	
	var file := FileAccess.open(backup_path, FileAccess.WRITE)
	if file == null:
		DebugManager.print_file_operations("SaveWriter: Could not create backup at %s" % backup_path, DebugManager.DebugLevel.WARNING)
		return false
	
	file.store_string(JSON.stringify(original_data))
	file.close()
	
	DebugManager.print_file_operations("SaveWriter: Created backup at %s" % backup_path)
	return true
#endregion
	
	