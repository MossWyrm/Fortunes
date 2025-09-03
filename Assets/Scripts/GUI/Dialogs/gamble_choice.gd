extends Control

## Gamble choice UI component
## Provides UI for players to choose gambling percentages for card effects.
## Integrates with the new EventBus architecture for gamble handling.

@onready var skip_button: Button = $MarginContainer/HBoxContainer/Skip
@onready var button_10: Button = $"MarginContainer/HBoxContainer/10"
@onready var button_25: Button = $"MarginContainer/HBoxContainer/25"
@onready var button_50: Button = $"MarginContainer/HBoxContainer/50"
@onready var button_100: Button = $"MarginContainer/HBoxContainer/100"

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_dialog()

# Connect button and EventBus signals
func _connect_signals() -> void:
	_connect_button_signals()
	_connect_event_bus_signals()

# Connect button press signals with their respective values
func _connect_button_signals() -> void:
	skip_button.pressed.connect(_choose_gamble_value.bind(GameConstants.PROGRESS_CLAMP_MIN))
	button_10.pressed.connect(_choose_gamble_value.bind(GameConstants.GAMBLE_TEN_PERCENT))
	button_25.pressed.connect(_choose_gamble_value.bind(GameConstants.GAMBLE_QUARTER_PERCENT))
	button_50.pressed.connect(_choose_gamble_value.bind(GameConstants.GAMBLE_HALF_PERCENT))
	button_100.pressed.connect(_choose_gamble_value.bind(GameConstants.GAMBLE_FULL_PERCENT))

# Connect to EventBus signals
func _connect_event_bus_signals() -> void:
	EventBus.gamble_choice_requested.connect(_on_gamble_choice_requested)

# Initialize dialog state
func _initialize_dialog() -> void:
	hide()  # Start hidden
#endregion

#region Gamble Logic
# Handle gamble choice request from EventBus
func _on_gamble_choice_requested() -> void:
	_show_gamble_dialog()

# Display the gamble choice dialog and pause game
func _show_gamble_dialog() -> void:
	_set_game_paused(true)
	show()

# Process the player's gamble choice and clean up
func _choose_gamble_value(gamble_percent: float) -> void:
	_emit_gamble_result(gamble_percent)
	_hide_dialog()

# Emit the gamble result through EventBus
func _emit_gamble_result(gamble_percent: float) -> void:
	EventBus.emit_gamble_chosen(gamble_percent)

# Hide the dialog and resume game
func _hide_dialog() -> void:
	hide()
	_set_game_paused(false)

# Pause or resume game drawing
func _set_game_paused(is_paused: bool) -> void:
	EventBus.emit_game_paused(is_paused)
#endregion