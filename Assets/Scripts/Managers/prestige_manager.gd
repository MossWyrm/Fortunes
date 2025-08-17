extends Node
class_name PrestigeManager
## Prestige system manager
##
## Handles pack completion rewards and deck resets.
## Manages the progression system when players complete packs.

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect to event bus signals
func _connect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(GameManager.game_state.event_bus.pack_completed, _on_pack_completed, "PrestigeManager pack completed")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(GameManager.game_state.event_bus.pack_completed, _on_pack_completed, "PrestigeManager pack completed")
#endregion

#region Event Handlers
# Handle pack completion and award rewards
func _on_pack_completed() -> void:
	_award_pack_completion_reward()
	_reset_deck_for_new_pack()

# Award currency for completing a pack
func _award_pack_completion_reward() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.currency_updated.emit(1, DataStructures.CurrencyType.PACK)

# Reset deck state for starting a new pack
func _reset_deck_for_new_pack() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.game_reset.emit(DataStructures.GameLayer.DECK)
#endregion