extends Node
class_name BuffDisplayManager

## Buff Display Manager
## Manages updates to all suit-specific buff displays when game state changes.
## Responds to shuffle events and display update requests from the EventBus.

@export var cup_display: BuffManager
@export var wand_display: BuffManager
@export var pentacles_display: BuffManager
@export var swords_display: BuffManager
@export var majors_display: BuffManager

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
		DebugManager.print_ui_displays("UpdateSuitDisplays: Found cup_display: " + cup_display.name, DebugManager.DebugLevel.VERBOSE)
	if wand_display: 
		managers.append(wand_display)
		DebugManager.print_ui_displays("UpdateSuitDisplays: Found wand_display: " + wand_display.name, DebugManager.DebugLevel.VERBOSE)
	if pentacles_display: 
		managers.append(pentacles_display)
		DebugManager.print_ui_displays("UpdateSuitDisplays: Found pentacles_display: " + pentacles_display.name, DebugManager.DebugLevel.VERBOSE)
	if swords_display: 
		managers.append(swords_display)
		DebugManager.print_ui_displays("UpdateSuitDisplays: Found swords_display: " + swords_display.name, DebugManager.DebugLevel.VERBOSE)
	if majors_display: 
		managers.append(majors_display)
		DebugManager.print_ui_displays("UpdateSuitDisplays: Found majors_display: " + majors_display.name, DebugManager.DebugLevel.VERBOSE)

	if managers.is_empty():
		DebugManager.print_ui_displays("UpdateSuitDisplays: No buff managers found", DebugManager.DebugLevel.WARNING)
		return

	DebugManager.print_ui_displays("UpdateSuitDisplays: Waiting for " + str(managers.size()) + " buff managers to initialize...", DebugManager.DebugLevel.INFO)
	var managers_to_wait: Array[BuffManager] = []
	
	for manager in managers:
		DebugManager.print_ui_displays("UpdateSuitDisplays: Checking " + manager.name + " initialization status: " + str(manager._initialization_complete), DebugManager.DebugLevel.VERBOSE)
		if not manager._initialization_complete:
			managers_to_wait.append(manager)
	
	# Wait for all managers to complete initialization
	while managers_to_wait.size() > 0:
		await get_tree().process_frame
		var i = 0
		while i < managers_to_wait.size():
			if managers_to_wait[i]._initialization_complete:
				DebugManager.print_ui_displays("UpdateSuitDisplays: BuffManager " + managers_to_wait[i].name + " initialization complete", DebugManager.DebugLevel.INFO)
				managers_to_wait.remove_at(i)
			else:
				i += 1

	DebugManager.print_ui_displays("UpdateSuitDisplays: All buff managers ready!", DebugManager.DebugLevel.INFO)

# Connect to event bus signals
func _connect_signals() -> void:
	EventBus.request_buff_update.connect(_on_suit_displays_update_requested)

# Send reference to card calculator
func _on_game_initialized():
	if ValidationUtils.has_card_calculator():
		GameManager.game_state.card_calculator.set_display_state_manager(self)
#endregion

#region Event Handlers
# Handle display update requests
func _on_suit_displays_update_requested(suit: DataStructures.SuitType, display_data: Dictionary) -> void:
	DebugManager.print_ui_displays("UpdateSuitDisplays: Received update request for suit %s with data: %s" % [suit, display_data], DebugManager.DebugLevel.INFO)
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