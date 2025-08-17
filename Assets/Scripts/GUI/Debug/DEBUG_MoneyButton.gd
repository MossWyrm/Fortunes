extends Button
## DEBUG: Currency addition button
##
## Development tool for adding currency to test purchases and upgrades.
## Should be removed or disabled in production builds.

#region Export Properties
@export var money_to_give: int = GameConstants.DEBUG_MONEY_AMOUNT
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button press signal using SignalManager for safe connections
func _connect_signals() -> void:
	SignalManager.safe_connect(pressed, _on_debug_give_money, "DEBUG money button")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(pressed, _on_debug_give_money, "DEBUG money button")
#endregion

#region Debug Functionality
# Add debug currency to the player
func _on_debug_give_money() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_currency_updated(
			money_to_give, 
			DataStructures.CurrencyType.CLAIRVOYANCE
		)
#endregion