extends Button

## Draw card button component
## Handles user input for drawing cards from the deck and clearing them.
## Integrates with the new EventBus architecture and includes button state management.

var input_made: bool = false
var disable_for_auto_draw: bool = false
var awaiting_player_input_selection: bool = false
var is_paused: bool = false

@onready var disable_overlay: Control = $TextureRect/DisableOverlay

#region Initialization
func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	pressed.connect(_on_button_pressed)
	EventBus.card_animation_finished.connect(_on_animation_finished)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.card_drawn.connect(_on_card_drawn)
	EventBus.player_input_requested.connect(_on_player_input_requested)
	EventBus.player_input_received.connect(_on_player_input_received)
#endregion

#region Button Interaction
func _draw_new_card() -> void:
	input_made = true	
	if not ValidationUtils.has_deck_manager():
		DebugManager.print_card_drawing("DrawCard: DeckManager not available, cannot draw card", DebugManager.DebugLevel.WARNING)
		return
	GameManager.game_state.deck_manager.draw_and_emit_card()

func _clear_current_card() -> void:
	EventBus.emit_clear_card()
#endregion

#region Event Handling
func _on_button_pressed() -> void:
	if not input_made:
		DebugManager.print_card_drawing("DrawCard: Attempting draw card")
		_draw_new_card()
	else:
		DebugManager.print_card_drawing("DrawCard: Clearing current card")
		_clear_current_card()

func _on_animation_finished() -> void:
	input_made = false

func _on_game_paused(disable_button: bool) -> void:
	is_paused = disable_button

func _on_player_input_requested() -> void:
	awaiting_player_input_selection = true

func _on_player_input_received() -> void:
	awaiting_player_input_selection = false

func _on_card_drawn(_card, _flipped) -> void:
	if input_made == false:
		input_made = true
#endregion

#region Public Access
# Force disable/enable the button (used by auto-draw)
func force_disable_button(should_disable: bool) -> void:
	disable_for_auto_draw = should_disable
#endregion

#region State Update
func _process(_delta: float) -> void:
	_update_button_state()

# Update button visual and interaction state
func _update_button_state() -> void:
	var should_be_disabled = awaiting_player_input_selection or disable_for_auto_draw or is_paused
	disable_overlay.visible = should_be_disabled
	disabled = should_be_disabled
#endregion