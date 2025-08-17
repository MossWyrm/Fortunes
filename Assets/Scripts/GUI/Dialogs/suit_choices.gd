extends Control
## Suit choice dialog component
##
## Provides UI for players to choose between different card suits.
## Integrates with the new EventBus architecture for suit selection.

#region Node References
@onready var cups_button: TextureButton = $MarginContainer/HBoxContainer/Cups
@onready var wands_button: TextureButton = $MarginContainer/HBoxContainer/Wands
@onready var pentacles_button: TextureButton = $MarginContainer/HBoxContainer/Pentacles
@onready var swords_button: TextureButton = $MarginContainer/HBoxContainer/Swords
@onready var majors_button: TextureButton = $MarginContainer/HBoxContainer/Majors
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_dialog()

# Connect button and EventBus signals
func _connect_signals() -> void:
	_connect_button_signals()
	_connect_event_bus_signals()

# Connect button press signals with their respective suit values
func _connect_button_signals() -> void:
	SignalManager.safe_connect(cups_button.pressed, _choose_suit.bind(DataStructures.SuitType.CUPS), "SuitChoice cups button")
	SignalManager.safe_connect(wands_button.pressed, _choose_suit.bind(DataStructures.SuitType.WANDS), "SuitChoice wands button")
	SignalManager.safe_connect(pentacles_button.pressed, _choose_suit.bind(DataStructures.SuitType.PENTACLES), "SuitChoice pentacles button")
	SignalManager.safe_connect(swords_button.pressed, _choose_suit.bind(DataStructures.SuitType.SWORDS), "SuitChoice swords button")
	SignalManager.safe_connect(majors_button.pressed, _choose_suit.bind(DataStructures.SuitType.MAJOR), "SuitChoice majors button")

# Connect to EventBus signals
func _connect_event_bus_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(GameManager.game_state.event_bus.suit_choice_requested, _on_suit_choice_requested, "SuitChoice choice requested")

# Initialize dialog state
func _initialize_dialog() -> void:
	hide()  # Start hidden

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(cups_button.pressed, _choose_suit.bind(DataStructures.SuitType.CUPS), "SuitChoice cups button")
	SignalManager.safe_disconnect(wands_button.pressed, _choose_suit.bind(DataStructures.SuitType.WANDS), "SuitChoice wands button")
	SignalManager.safe_disconnect(pentacles_button.pressed, _choose_suit.bind(DataStructures.SuitType.PENTACLES), "SuitChoice pentacles button")
	SignalManager.safe_disconnect(swords_button.pressed, _choose_suit.bind(DataStructures.SuitType.SWORDS), "SuitChoice swords button")
	SignalManager.safe_disconnect(majors_button.pressed, _choose_suit.bind(DataStructures.SuitType.MAJOR), "SuitChoice majors button")
	
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(GameManager.game_state.event_bus.suit_choice_requested, _on_suit_choice_requested, "SuitChoice choice requested")
#endregion

#region Suit Choice Logic
# Handle suit choice request from EventBus
func _on_suit_choice_requested(include_majors: bool) -> void:
	_show_suit_dialog(include_majors)

# Display the suit choice dialog and configure major button visibility
func _show_suit_dialog(include_majors: bool) -> void:
	_set_game_paused(true)
	majors_button.visible = include_majors
	show()

# Process the player's suit choice and clean up
func _choose_suit(chosen_suit: DataStructures.SuitType) -> void:
	_emit_suit_result(chosen_suit)
	_hide_dialog()

# Emit the suit choice result through EventBus
func _emit_suit_result(chosen_suit: DataStructures.SuitType) -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_suit_chosen(chosen_suit)

# Hide the dialog and resume game
func _hide_dialog() -> void:
	hide()
	_set_game_paused(false)

# Pause or resume game drawing
func _set_game_paused(is_paused: bool) -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_game_paused(is_paused)
#endregion