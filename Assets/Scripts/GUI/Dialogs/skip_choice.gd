extends Control

## Skip choice UI component
## Provides UI for players to choose whether to skip or continue with card effects.
## Integrates with the new EventBus architecture for choice handling.

@onready var skip_button: Button = $MarginContainer/HBoxContainer/SkipButton
@onready var continue_button: Button = $MarginContainer/HBoxContainer/ContinueButton

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_dialog()

# Connect button and EventBus signals
func _connect_signals() -> void:
	_connect_button_signals()
	_connect_event_bus_signals()

# Connect button press signals
func _connect_button_signals() -> void:
	skip_button.pressed.connect(_on_skip_selected)
	continue_button.pressed.connect(_on_continue_selected)

# Connect to EventBus signals
func _connect_event_bus_signals() -> void:
	# Direct EventBus connection - always available as autoload
	EventBus.skip_choice_requested.connect(_on_skip_choice_requested)

# Initialize dialog state
func _initialize_dialog() -> void:
	hide()  # Start hidden
#endregion

#region Choice Logic
# Handle skip choice request from EventBus
func _on_skip_choice_requested() -> void:
	_show_skip_dialog()

# Display the skip choice dialog and pause game
func _show_skip_dialog() -> void:
	_set_game_paused(true)
	show()

# Handle skip button press
func _on_skip_selected() -> void:
	_make_choice(true)

# Handle continue button press
func _on_continue_selected() -> void:
	_make_choice(false)

# Process the player's choice and clean up
func _make_choice(should_skip: bool) -> void:
	_emit_choice_result(should_skip)
	_hide_dialog()

# Emit the choice result through EventBus
func _emit_choice_result(should_skip: bool) -> void:
	EventBus.emit_skip_chosen(should_skip)

# Hide the dialog and resume game
func _hide_dialog() -> void:
	hide()
	_set_game_paused(false)

# Pause or resume game drawing
func _set_game_paused(is_paused: bool) -> void:
	if GameManager.game_state:
		EventBus.emit_game_paused(is_paused)
#endregion
	