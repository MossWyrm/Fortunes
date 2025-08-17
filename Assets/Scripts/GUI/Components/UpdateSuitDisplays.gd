extends Node
class_name UpdateSuitDisplays
## Suit display updater component
##
## Manages updates to all suit-specific buff displays when game state changes.
## Responds to shuffle events and display update requests from the EventBus.

#region Export Properties
@export var cup_display: BuffManager
@export var wand_display: BuffManager
@export var pentacles_display: BuffManager
@export var swords_display: BuffManager
@export var majors_display: BuffManager
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initial_update()

# Connect to event bus signals
func _connect_signals() -> void:
	if ValidationUtils.has_event_bus():
		var event_bus = GameManager.game_state.event_bus
		SignalManager.safe_connect(event_bus.deck_shuffled, _on_deck_shuffled, "UpdateSuitDisplays deck shuffled")
		SignalManager.safe_connect(event_bus.suit_displays_update_requested, _on_suit_displays_update_requested, "UpdateSuitDisplays update requested")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		var event_bus = GameManager.game_state.event_bus
		SignalManager.safe_disconnect(event_bus.deck_shuffled, _on_deck_shuffled, "UpdateSuitDisplays deck shuffled")
		SignalManager.safe_disconnect(event_bus.suit_displays_update_requested, _on_suit_displays_update_requested, "UpdateSuitDisplays update requested")

# Perform initial display update
func _initial_update() -> void:
	update_suit_displays()
#endregion

#region Event Handlers
# Handle deck shuffle events
func _on_deck_shuffled(_safely: bool) -> void:
	# Wait a frame to ensure all calculations are complete
	await get_tree().process_frame
	update_suit_displays()

# Handle display update requests
func _on_suit_displays_update_requested() -> void:
	update_suit_displays()
#endregion

#region Display Updates
# Update all suit displays with current values
func update_suit_displays() -> void:
	if not GameManager.game_state or not GameManager.game_state.cv_manager:
		push_warning("UpdateSuitDisplays: No CV manager available for display updates")
		return
	
	var cv_manager = GameManager.game_state.cv_manager
	
	# Update each suit display if components exist
	if cup_display:
		cup_display.update_display(cv_manager.get_display(DataStructures.SuitType.CUPS))
	
	if wand_display:
		wand_display.update_display(cv_manager.get_display(DataStructures.SuitType.WANDS))
	
	if pentacles_display:
		pentacles_display.update_display(cv_manager.get_display(DataStructures.SuitType.PENTACLES))
	
	if swords_display:
		swords_display.update_display(cv_manager.get_display(DataStructures.SuitType.SWORDS))
	
	if majors_display:
		majors_display.update_display(cv_manager.get_display(DataStructures.SuitType.MAJOR))
#endregion