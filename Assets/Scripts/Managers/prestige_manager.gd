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
	EventBus.pack_complete.connect(_on_pack_completed)
#endregion

#region Event Handlers
# Handle pack completion and award rewards
func _on_pack_completed() -> void:
	_award_pack_completion_reward()
	_reset_deck_for_new_pack()

# Award currency for completing a pack
func _award_pack_completion_reward() -> void:
	EventBus.currency_updated.emit(1, DataStructures.CurrencyType.PACK)

# Reset deck state for starting a new pack
func _reset_deck_for_new_pack() -> void:
	EventBus.game_reset.emit(DataStructures.GameLayer.DECK)
#endregion