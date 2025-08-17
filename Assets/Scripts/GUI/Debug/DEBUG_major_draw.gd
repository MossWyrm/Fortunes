extends Button
## DEBUG: Major card draw button
##
## Development tool for forcing major arcana card draws.
## Should be removed or disabled in production builds.

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button press signal using SignalManager for safe connections
func _connect_signals() -> void:
	SignalManager.safe_connect(pressed, _on_debug_draw_major, "DEBUG major draw button")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(pressed, _on_debug_draw_major, "DEBUG major draw button")
#endregion

#region Debug Functionality
# Force draw a major arcana card for debugging
func _on_debug_draw_major() -> void:
	if ValidationUtils.has_deck_manager():
		# Check if debug_draw_major method exists
		if GameManager.game_state.deck_manager.has_method("debug_draw_major"):
			GameManager.game_state.deck_manager.debug_draw_major()
		else:
			# Fallback: draw a random major card manually
			_force_draw_major_card()

# Fallback method to draw a major card if debug method doesn't exist
func _force_draw_major_card() -> void:
	var major_card_id = randi_range(GameConstants.MAJOR_CARD_THRESHOLD, GameConstants.MAJOR_CARD_THRESHOLD + GameConstants.MAJOR_CARD_COUNT - 1)
	if ValidationUtils.has_deck_manager():
		var card = GameManager.game_state.deck_manager.get_card(major_card_id)
		if card and ValidationUtils.has_event_bus():
			GameManager.game_state.event_bus.emit_card_drawn(card, false)
#endregion