extends RefCounted
class_name SignalManager
## Comprehensive signal management utility
##
## Provides safe connection/disconnection methods to prevent crashes,
## double-connections, and memory leaks in EventBus signal management.

#region Basic Signal Safety
# Safely connect a signal with optional description (prevents double-connections)
static func safe_connect(signal_source: Signal, target_method: Callable, description: String = "", flags: int = 0) -> bool:
	if signal_source.is_connected(target_method):
		if description:
			push_warning("SignalManager: Signal already connected for %s" % description)
		return false  # Already connected, skip silently
	
	signal_source.connect(target_method, flags)
	if description and GameConstants.DEBUG_ENABLED:
		print("SignalManager: Connected %s" % description)
	return true

# Safely disconnect a signal (no error if not connected)
static func safe_disconnect(signal_source: Signal, target_method: Callable, description: String = "") -> bool:
	if not signal_source.is_connected(target_method):
		return false  # Not connected, skip silently
	
	signal_source.disconnect(target_method)
	if description and GameConstants.DEBUG_ENABLED:
		print("SignalManager: Disconnected %s" % description)
	return true
#endregion

#region EventBus Helper (Simple Version)
# Connect to EventBus with null safety - simple version
static func connect_to_event_bus(signal_name: String, target_method: Callable) -> bool:
	if not GameManager.game_state or not GameManager.game_state.event_bus:
		push_warning("SignalManager: EventBus not available for signal: %s" % signal_name)
		return false
	
	var event_bus = GameManager.game_state.event_bus
	var signal_source = event_bus.get(signal_name)
	
	if signal_source == null:
		push_warning("SignalManager: Signal '%s' not found on EventBus" % signal_name)
		return false
	
	return safe_connect(signal_source, target_method)

# Disconnect from EventBus with null safety
static func disconnect_from_event_bus(signal_name: String, target_method: Callable) -> bool:
	if not GameManager.game_state or not GameManager.game_state.event_bus:
		return false
	
	var event_bus = GameManager.game_state.event_bus
	var signal_source = event_bus.get(signal_name)
	
	if signal_source == null:
		return false
	
	return safe_disconnect(signal_source, target_method)
#endregion

#region Node Lifecycle Helpers
# Helper for nodes that need to disconnect signals in _exit_tree()
static func disconnect_node_signals(node: Node, signal_connections: Array[Dictionary]) -> void:
	"""
	Disconnect multiple signals for a node during cleanup.
	signal_connections format: [{"signal": Signal, "method": Callable, "description": String}]
	"""
	for connection in signal_connections:
		var signal_source = connection.get("signal")
		var method = connection.get("method") 
		var description = connection.get("description", "")
		
		if signal_source and method:
			safe_disconnect(signal_source, method, description)

# Disconnect all EventBus signals for a node (common cleanup pattern)
static func disconnect_all_event_bus_signals(target_node: Node) -> void:
	"""
	Attempts to disconnect common EventBus signals for a node.
	Useful for general cleanup in _exit_tree().
	"""
	if not ValidationUtils.has_event_bus():
		return
		
	var event_bus = GameManager.game_state.event_bus
	var common_signals = [
		"card_drawn", "card_calculated", "currency_updated", "game_reset", 
		"game_paused", "suit_chosen", "upgrade_purchased", "card_animation_finished"
	]
	
	for signal_name in common_signals:
		var signal_source = event_bus.get(signal_name)
		if signal_source:
			# Try to disconnect any method from the target node
			var connections = signal_source.get_connections()
			for connection in connections:
				if connection.callable.get_object() == target_node:
					safe_disconnect(signal_source, connection.callable, "Auto-cleanup %s" % signal_name)
#endregion
