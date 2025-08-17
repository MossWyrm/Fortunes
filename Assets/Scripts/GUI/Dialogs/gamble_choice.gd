extends Control
## Gamble choice dialog component
##
## Provides UI for players to choose gambling percentages for card effects.
## Integrates with the new EventBus architecture for gamble handling.

#region Node References
@onready var skip_button: Button = $MarginContainer/HBoxContainer/Skip
@onready var button_10: Button = $"MarginContainer/HBoxContainer/10"
@onready var button_25: Button = $"MarginContainer/HBoxContainer/25"
@onready var button_50: Button = $"MarginContainer/HBoxContainer/50"
@onready var button_100: Button = $"MarginContainer/HBoxContainer/100"
#endregion

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
	SignalManager.safe_connect(skip_button.pressed, _choose_gamble_value.bind(GameConstants.PROGRESS_CLAMP_MIN), "GambleChoice skip button")
	SignalManager.safe_connect(button_10.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_TEN_PERCENT), "GambleChoice 10% button")
	SignalManager.safe_connect(button_25.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_QUARTER_PERCENT), "GambleChoice 25% button")
	SignalManager.safe_connect(button_50.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_HALF_PERCENT), "GambleChoice 50% button")
	SignalManager.safe_connect(button_100.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_FULL_PERCENT), "GambleChoice 100% button")

# Connect to EventBus signals
func _connect_event_bus_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(GameManager.game_state.event_bus.gamble_choice_requested, _on_gamble_choice_requested, "GambleChoice choice requested")

# Initialize dialog state
func _initialize_dialog() -> void:
	hide()  # Start hidden

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(skip_button.pressed, _choose_gamble_value.bind(GameConstants.PROGRESS_CLAMP_MIN), "GambleChoice skip button")
	SignalManager.safe_disconnect(button_10.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_TEN_PERCENT), "GambleChoice 10% button")
	SignalManager.safe_disconnect(button_25.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_QUARTER_PERCENT), "GambleChoice 25% button")
	SignalManager.safe_disconnect(button_50.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_HALF_PERCENT), "GambleChoice 50% button")
	SignalManager.safe_disconnect(button_100.pressed, _choose_gamble_value.bind(GameConstants.GAMBLE_FULL_PERCENT), "GambleChoice 100% button")
	
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(GameManager.game_state.event_bus.gamble_choice_requested, _on_gamble_choice_requested, "GambleChoice choice requested")
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
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_gamble_chosen(gamble_percent)

# Hide the dialog and resume game
func _hide_dialog() -> void:
	hide()
	_set_game_paused(false)

# Pause or resume game drawing
func _set_game_paused(is_paused: bool) -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_game_paused(is_paused)
#endregion