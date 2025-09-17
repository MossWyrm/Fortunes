extends Node

@export_group("Debug Settings")
@export var debug_mode: bool = true
@export var current_level: DebugLevel = DebugLevel.INFO

@export_group("Debug Categories") 
@export var enable_card_management: bool = true
@export var enable_deck_operations: bool = true
@export var enable_card_drawing: bool = true
@export var enable_card_animations: bool = true
@export var enable_card_effects: bool = true
@export var enable_upgrades_system: bool = true
@export var enable_audio_system: bool = true
@export var enable_ui_interactions: bool = true
@export var enable_ui_displays: bool = true
@export var enable_game_state: bool = true
@export var enable_player_stats: bool = true
@export var enable_file_operations: bool = true
@export var enable_networking: bool = false
@export var enable_system_general: bool = true

enum DebugLevel {
	VERBOSE,
	INFO, 
	WARNING,
	ERROR
}

enum DebugCategory {
	CARD_MANAGEMENT,    # Card creation, properties, validation
	DECK_OPERATIONS,    # Deck shuffling, building, modification
	CARD_DRAWING,       # Drawing cards, hand management
	CARD_ANIMATIONS,    # All card animation states and timing
	CARD_EFFECTS,       # Card effects, interactions, and triggers
	UPGRADES_SYSTEM,    # Upgrade application, effects
	AUDIO_SYSTEM,       # Sound effects, music, audio loading
	UI_INTERACTIONS,    # Button clicks, menu navigation, tooltips
	UI_DISPLAYS,        # UI element visibility, updates
	GAME_STATE,         # Game flow, turns, win conditions
	PLAYER_STATS,       # Stats calculations, progression
	FILE_OPERATIONS,    # Save/load, file I/O
	NETWORKING,         # Multiplayer, online features
	SYSTEM_GENERAL      # General system messages, errors
}


# INITIALIZATION
func _ready() -> void:
	if debug_mode:
		print("[DEBUG] DebugManager initialized - Level: %s" % _level_to_string(current_level))
		print("[DEBUG] Enabled categories: \n - %s" % _get_enabled_categories_string())

# CATEGORY MANAGEMENT
func is_category_enabled(category: DebugCategory) -> bool:
	match category:
		DebugCategory.CARD_MANAGEMENT: return enable_card_management
		DebugCategory.DECK_OPERATIONS: return enable_deck_operations
		DebugCategory.CARD_DRAWING: return enable_card_drawing
		DebugCategory.CARD_ANIMATIONS: return enable_card_animations
		DebugCategory.CARD_EFFECTS: return enable_card_effects
		DebugCategory.UPGRADES_SYSTEM: return enable_upgrades_system
		DebugCategory.AUDIO_SYSTEM: return enable_audio_system
		DebugCategory.UI_INTERACTIONS: return enable_ui_interactions
		DebugCategory.UI_DISPLAYS: return enable_ui_displays
		DebugCategory.GAME_STATE: return enable_game_state
		DebugCategory.PLAYER_STATS: return enable_player_stats
		DebugCategory.FILE_OPERATIONS: return enable_file_operations
		DebugCategory.NETWORKING: return enable_networking
		DebugCategory.SYSTEM_GENERAL: return enable_system_general
		_: return false

func should_log(level: DebugLevel, category: DebugCategory) -> bool:
	return debug_mode and level >= current_level and is_category_enabled(category)

# LOGGING METHODS
func log_verbose(message: String, category: DebugCategory = DebugCategory.SYSTEM_GENERAL) -> void:
	if should_log(DebugLevel.VERBOSE, category):
		_print_with_format("VERBOSE", message, category)

func log_info(message: String, category: DebugCategory = DebugCategory.SYSTEM_GENERAL) -> void:
	if should_log(DebugLevel.INFO, category):
		_print_with_format("INFO", message, category)

func log_warning(message: String, category: DebugCategory = DebugCategory.SYSTEM_GENERAL) -> void:
	if should_log(DebugLevel.WARNING, category):
		_print_with_format("WARNING", message, category)

func log_error(message: String, category: DebugCategory = DebugCategory.SYSTEM_GENERAL) -> void:
	if should_log(DebugLevel.ERROR, category):
		_print_with_format("ERROR", message, category)

# CONVENIENCE METHODS (Project-Specific)
func print_card_management(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.CARD_MANAGEMENT):
		_print_with_format(_level_to_string(level), message, DebugCategory.CARD_MANAGEMENT)

func print_deck_operations(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.DECK_OPERATIONS):
		_print_with_format(_level_to_string(level), message, DebugCategory.DECK_OPERATIONS)

func print_card_drawing(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.CARD_DRAWING):
		_print_with_format(_level_to_string(level), message, DebugCategory.CARD_DRAWING)

func print_card_animations(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.CARD_ANIMATIONS):
		_print_with_format(_level_to_string(level), message, DebugCategory.CARD_ANIMATIONS)

func print_card_effects(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.CARD_EFFECTS):
		_print_with_format(_level_to_string(level), message, DebugCategory.CARD_EFFECTS)

func print_upgrades_system(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.UPGRADES_SYSTEM):
		_print_with_format(_level_to_string(level), message, DebugCategory.UPGRADES_SYSTEM)

func print_audio_system(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.AUDIO_SYSTEM):
		_print_with_format(_level_to_string(level), message, DebugCategory.AUDIO_SYSTEM)

func print_ui_interactions(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.UI_INTERACTIONS):
		_print_with_format(_level_to_string(level), message, DebugCategory.UI_INTERACTIONS)

func print_ui_displays(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.UI_DISPLAYS):
		_print_with_format(_level_to_string(level), message, DebugCategory.UI_DISPLAYS)

func print_game_state(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.GAME_STATE):
		_print_with_format(_level_to_string(level), message, DebugCategory.GAME_STATE)

func print_player_stats(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.PLAYER_STATS):
		_print_with_format(_level_to_string(level), message, DebugCategory.PLAYER_STATS)

func print_file_operations(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.FILE_OPERATIONS):
		_print_with_format(_level_to_string(level), message, DebugCategory.FILE_OPERATIONS)

func print_networking(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.NETWORKING):
		_print_with_format(_level_to_string(level), message, DebugCategory.NETWORKING)

func print_system_general(message: String, level: DebugLevel = DebugLevel.INFO) -> void:
	if should_log(level, DebugCategory.SYSTEM_GENERAL):
		_print_with_format(_level_to_string(level), message, DebugCategory.SYSTEM_GENERAL)

# INTERNAL METHODS
func _print_with_format(level_str: String, message: String, category: DebugCategory) -> void:
	var timestamp = Time.get_time_string_from_system()
	var category_str = _category_to_string(category)
	print("[%s] [%s] [%s] %s" % [timestamp, level_str, category_str, message])

func _level_to_string(level: DebugLevel) -> String:
	match level:
		DebugLevel.VERBOSE: return "VERBOSE"
		DebugLevel.INFO: return "INFO"
		DebugLevel.WARNING: return "WARNING"
		DebugLevel.ERROR: return "ERROR"
		_: return "UNKNOWN"

func _category_to_string(category: DebugCategory) -> String:
	match category:
		DebugCategory.CARD_MANAGEMENT: return "CARDS"
		DebugCategory.DECK_OPERATIONS: return "DECK"
		DebugCategory.CARD_DRAWING: return "DRAW"
		DebugCategory.CARD_ANIMATIONS: return "ANIM"
		DebugCategory.CARD_EFFECTS: return "EFFECTS"
		DebugCategory.UPGRADES_SYSTEM: return "UPGRADES"
		DebugCategory.AUDIO_SYSTEM: return "AUDIO"
		DebugCategory.UI_INTERACTIONS: return "UI"
		DebugCategory.UI_DISPLAYS: return "UI-DISPLAY"
		DebugCategory.GAME_STATE: return "GAME"
		DebugCategory.PLAYER_STATS: return "STATS"
		DebugCategory.FILE_OPERATIONS: return "FILE"
		DebugCategory.NETWORKING: return "NET"
		DebugCategory.SYSTEM_GENERAL: return "SYSTEM"
		_: return "UNKNOWN"

func _get_enabled_categories_string() -> String:
	var enabled = []
	for category in DebugCategory.values():
		if is_category_enabled(category):
			enabled.append(_category_to_string(category))
	return "\n - ".join(enabled)

