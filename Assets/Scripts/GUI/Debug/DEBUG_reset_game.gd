extends Button
## DEBUG: Game reset button
##
## Development tool for resetting game state during testing.
## Should be removed or disabled in production builds.

#region Initialization
func _ready() -> void:
	_connect_signals()

func _connect_signals() -> void:
	pressed.connect(_on_debug_reset_game)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if pressed.is_connected(_on_debug_reset_game):
		pressed.disconnect(_on_debug_reset_game)
#endregion

#region Debug Functionality
# Reset the entire game state for debugging
func _on_debug_reset_game() -> void:
	if ValidationUtils.has_event_bus():
		EventBus.emit_game_reset(DataStructures.GameLayer.ALL)
#endregion