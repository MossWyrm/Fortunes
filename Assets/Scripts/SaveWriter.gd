extends RefCounted
class_name SaveWriter

const SAVE_GAME_PATH := "user://save.json"

var version := 1

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_GAME_PATH)
	
func write_savegame(data: Dictionary) -> void:
	print("Attempting save")
	var _file := FileAccess.open(SAVE_GAME_PATH, FileAccess.WRITE)
	if _file == null:
		printerr("Could not open the file %s. Aborting save operation. Error code: %s." %
		[SAVE_GAME_PATH, FileAccess.get_open_error()])
		return
		
	var json_string := JSON.stringify(data)
	_file.store_string(json_string)
	_file.close()
	print("Save completed.")
	
func load_savegame() -> Dictionary:
	var _file := FileAccess.open(SAVE_GAME_PATH, FileAccess.READ)
	if _file == null:
		printerr("Could not open the file %s. Aborting load operation. Error code: %s." %
		[SAVE_GAME_PATH, FileAccess.get_open_error()])
		return {}
		
	var json_string := _file.get_as_text()
	_file.close()
	
	var json := JSON.new()
	var error = json.parse(json_string)
	var data: Dictionary = json.data
	if error != OK:
		printerr("JSON Parse Error: %s in %s at line %s." %
		[ json.get_error_message(), json_string, json.get_error_line()])
		return { }
	return data
	
func clear_save() -> void:
	var _file := DirAccess.open("user://")
	_file.remove("save.json")
	
	