extends Node
class_name DisplayStateManager
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
	await _ensure_buff_managers_ready()
	_connect_signals()

# Wait for all buff managers to finish initialization
func _ensure_buff_managers_ready() -> void:
	var managers: Array[BuffManager] = []
	
	# Collect all available buff managers
	if cup_display: 
		managers.append(cup_display)
		print("UpdateSuitDisplays: Found cup_display: ", cup_display.name)
	if wand_display: 
		managers.append(wand_display)
		print("UpdateSuitDisplays: Found wand_display: ", wand_display.name)
	if pentacles_display: 
		managers.append(pentacles_display)
		print("UpdateSuitDisplays: Found pentacles_display: ", pentacles_display.name)
	if swords_display: 
		managers.append(swords_display)
		print("UpdateSuitDisplays: Found swords_display: ", swords_display.name)
	if majors_display: 
		managers.append(majors_display)
		print("UpdateSuitDisplays: Found majors_display: ", majors_display.name)
	
	if managers.is_empty():
		print("UpdateSuitDisplays: No buff managers found")
		return
	
	print("UpdateSuitDisplays: Waiting for ", managers.size(), " buff managers to initialize...")
	var managers_to_wait: Array[BuffManager] = []
	
	for manager in managers:
		print("UpdateSuitDisplays: Checking ", manager.name, " initialization status: ", manager._initialization_complete)
		if not manager._initialization_complete:
			managers_to_wait.append(manager)
	
	# Wait for all managers to complete initialization
	while managers_to_wait.size() > 0:
		await get_tree().process_frame
		var i = 0
		while i < managers_to_wait.size():
			if managers_to_wait[i]._initialization_complete:
				print("UpdateSuitDisplays: BuffManager ", managers_to_wait[i].name, " initialization complete")
				managers_to_wait.remove_at(i)
			else:
				i += 1
	
	print("UpdateSuitDisplays: All buff managers ready!")

# Connect to event bus signals
func _connect_signals() -> void:
	EventBus.request_buff_update.connect(_on_suit_displays_update_requested)

# Send reference to card calculator
func _on_game_initialized():
	if ValidationUtils.has_card_calculator():
		GameManager.game_state.card_calculator.set_display_state_manager(self)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	EventBus.request_buff_update.disconnect(_on_suit_displays_update_requested)
#endregion

#region Event Handlers
# Handle display update requests
func _on_suit_displays_update_requested(suit: DataStructures.SuitType, display_data: Dictionary) -> void:
	match suit:
		DataStructures.SuitType.CUPS:
			if cup_display:
				cup_display.update_display(display_data)
		DataStructures.SuitType.WANDS:
			if wand_display:
				wand_display.update_display(display_data)
		DataStructures.SuitType.PENTACLES:
			if pentacles_display:
				pentacles_display.update_display(display_data)
		DataStructures.SuitType.SWORDS:
			if swords_display:
				swords_display.update_display(display_data)
		DataStructures.SuitType.MAJOR:
			if majors_display:
				majors_display.update_display(display_data)
		_:
			push_warning("UpdateSuitDisplays: Unknown suit type %s" % suit)
#endregion