extends Control

## Suit choice UI component
## Provides UI for players to choose between different card suits.
## Integrates with the new EventBus architecture for suit selection.

@onready var cups_button: TextureButton = $MarginContainer/HBoxContainer/Cups
@onready var wands_button: TextureButton = $MarginContainer/HBoxContainer/Wands
@onready var pentacles_button: TextureButton = $MarginContainer/HBoxContainer/Pentacles
@onready var swords_button: TextureButton = $MarginContainer/HBoxContainer/Swords
@onready var majors_button: TextureButton = $MarginContainer/HBoxContainer/Majors

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
	cups_button.pressed.connect(_choose_suit.bind(DataStructures.SuitType.CUPS))
	wands_button.pressed.connect(_choose_suit.bind(DataStructures.SuitType.WANDS))
	pentacles_button.pressed.connect(_choose_suit.bind(DataStructures.SuitType.PENTACLES))
	swords_button.pressed.connect(_choose_suit.bind(DataStructures.SuitType.SWORDS))
	majors_button.pressed.connect(_choose_suit.bind(DataStructures.SuitType.MAJOR))

# Connect to EventBus signals
func _connect_event_bus_signals() -> void:
	EventBus.suit_choice_requested.connect(_on_suit_choice_requested)

func _initialize_dialog() -> void:
	hide()
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
	EventBus.emit_suit_chosen(chosen_suit)

# Hide the dialog and resume game
func _hide_dialog() -> void:
	hide()
	_set_game_paused(false)

# Pause or resume game drawing
func _set_game_paused(is_paused: bool) -> void:
	EventBus.emit_game_paused(is_paused)
#endregion