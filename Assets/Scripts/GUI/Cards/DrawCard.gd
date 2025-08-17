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
	SignalManager.safe_connect(pressed, _on_button_pressed, "DrawCard button")
	_connect_event_bus_signals()

# Connect to EventBus signals for state management
func _connect_event_bus_signals() -> void:
	if ValidationUtils.has_event_bus():
		var event_bus = GameManager.game_state.event_bus
		SignalManager.safe_connect(event_bus.card_animation_finished, _on_animation_finished, "DrawCard animation finished")
		SignalManager.safe_connect(event_bus.game_paused, _on_game_paused, "DrawCard game paused")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(pressed, _on_button_pressed, "DrawCard button")
	
	if ValidationUtils.has_event_bus():
		var event_bus = GameManager.game_state.event_bus
		SignalManager.safe_disconnect(event_bus.card_animation_finished, _on_animation_finished, "DrawCard animation finished")
		SignalManager.safe_disconnect(event_bus.game_paused, _on_game_paused, "DrawCard game paused")
#endregion

#region Button Interaction
# Handle button press - draw card or clear current card
func _on_button_pressed() -> void:
	if not input_made:
		_draw_new_card()
	else:
		_clear_current_card()

# Draw a new card from the deck
func _draw_new_card() -> void:
	input_made = true
	
	if not ValidationUtils.has_deck_manager():
		return
	
	var card = GameManager.game_state.deck_manager.draw_card()
	if card:
		# Determine if card should be flipped (implement your game logic)
		var is_flipped = _should_card_be_flipped(card)
		
		# Emit card drawn signal
		if ValidationUtils.has_event_bus():
			GameManager.game_state.event_bus.emit_card_drawn(card, is_flipped)

# Clear the currently displayed card
func _clear_current_card() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_clear_card()

# Determine if a card should be drawn flipped - implement your game logic
func _should_card_be_flipped(_card: Card) -> bool:
	# TODO: Implement your card flipping logic here
	return false
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
func _update_button_state(is_disabled: bool) -> void:
	var should_be_disabled = is_disabled or force_disable
	disable_overlay.visible = should_be_disabled
	disabled = should_be_disabled
#endregion