extends Button
## DEBUG: Game reset button
##
## Development tool for resetting game state during testing.
## Should be removed or disabled in production builds.

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button press signal using SignalManager for safe connections
func _connect_signals() -> void:
	SignalManager.safe_connect(pressed, _on_debug_reset_game, "DEBUG reset game button")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(pressed, _on_debug_reset_game, "DEBUG reset game button")
#endregion

#region Debug Functionality
# Reset the entire game state for debugging
func _on_debug_reset_game() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_game_reset(DataStructures.GameLayer.ALL)
#endregion