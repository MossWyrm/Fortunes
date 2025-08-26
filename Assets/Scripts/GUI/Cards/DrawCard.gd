extends Button
## Draw card button component
##
## Handles user input for drawing cards from the deck and clearing them.
## Integrates with the new EventBus architecture and includes button state management.

#region Properties
var input_made: bool = false
var force_disable: bool = false
#endregion

#region Node References
@onready var disable_overlay: Control = $TextureRect/DisableOverlay
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button and EventBus signals
func _connect_signals() -> void:
	_connect_event_bus_signals()
	pressed.connect(_on_button_pressed)

# Connect to EventBus signals for state management
func _connect_event_bus_signals() -> void:
	# Direct EventBus connections - always available as autoload
	EventBus.card_animation_finished.connect(_on_animation_finished)
	EventBus.game_paused.connect(_on_game_paused)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if pressed.is_connected(_on_button_pressed):
		pressed.disconnect(_on_button_pressed)
	
	if EventBus.card_animation_finished.is_connected(_on_animation_finished):
		EventBus.card_animation_finished.disconnect(_on_animation_finished)
	if EventBus.game_paused.is_connected(_on_game_paused):
		EventBus.game_paused.disconnect(_on_game_paused)
#endregion

#region Button Interaction
# Handle button press - draw card or clear current card
func _on_button_pressed() -> void:
	if not input_made:
		print("Attempting draw card")
		_draw_new_card()
	else:
		print("Clearing current card")
		_clear_current_card()

# Draw a new card from the deck
func _draw_new_card() -> void:
	input_made = true
	
	if not ValidationUtils.has_deck_manager():
		push_warning("DrawCard: DeckManager not available, cannot draw card")
		return
	
	# Let DeckManager handle the complete draw process including inversion logic
	GameManager.game_state.deck_manager.draw_and_emit_card()

# Clear the currently displayed card
func _clear_current_card() -> void:
	if ValidationUtils.has_event_bus():
		EventBus.emit_clear_card()
#endregion

#region State Management
# Release button lock when animation completes
func _on_animation_finished(_card: Card) -> void:
	input_made = false

# Handle game pause state
func _on_game_paused(is_paused: bool) -> void:
	_update_button_state(is_paused)

# Force disable/enable the button (used by auto-draw)
func force_disable_button(should_disable: bool) -> void:
	force_disable = should_disable
	_update_button_state(should_disable)

# Update button visual and interaction state
func _update_button_state(should_disable: bool) -> void:
	var should_be_disabled = should_disable or force_disable
	disable_overlay.visible = should_be_disabled
	disabled = should_be_disabled
#endregion