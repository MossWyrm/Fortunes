extends Control
class_name DeckCreatorNavigator

## Deck creator suit panel navigator
## Manages navigation between different suit panels in the deck creator interface.
## Handles panel visibility and button selection states for smooth user experience.

@export var cups_panel: ScrollContainer
@export var wands_panel: ScrollContainer
@export var pentacles_panel: ScrollContainer
@export var swords_panel: ScrollContainer
@export var majors_panel: ScrollContainer
@export var buttons: Array[DeckCreatorNavButton] = []

var panels: Dictionary[DataStructures.SuitType, ScrollContainer] = {}
var deck_creator: DeckCreator

#region Initialization
func _ready() -> void:
	_initialize_panels()

# Initialize the panels array with all suit panels
func _initialize_panels() -> void:
	panels.clear()
	
	if cups_panel:
		panels[DataStructures.SuitType.CUPS] = cups_panel
	if wands_panel:
		panels[DataStructures.SuitType.WANDS] = wands_panel
	if pentacles_panel:
		panels[DataStructures.SuitType.PENTACLES] = pentacles_panel
	if swords_panel:
		panels[DataStructures.SuitType.SWORDS] = swords_panel
	if majors_panel:
		panels[DataStructures.SuitType.MAJOR] = majors_panel

	if panels.size() != 5:
		DebugManager.print_ui_displays("DeckCreatorNavigator: Expected 5 panels, found %d" % panels.size(), DebugManager.DebugLevel.WARNING)
#endregion

#region Panel Navigation
# Open a specific panel and update button states
func open_panel(texture_button: TextureButton, panel_number: int) -> void:
	if not _is_valid_panel_number(panel_number):
		DebugManager.print_deck_operations("DeckCreatorNavigator: Invalid panel number: %d" % panel_number, DebugManager.DebugLevel.WARNING)
		return
	DebugManager.print_deck_operations("DeckCreatorNavigator: Switching to panel %d" % panel_number)
	_switch_to_panel(panel_number)
	_update_button_selection(texture_button)

# Switch visibility to the specified panel
func _switch_to_panel(target_panel: int) -> void:
	deck_creator.currently_active_suit = DataStructures.SuitType.values()[target_panel]
	for i in panels.size():
		var panel = panels[i]
		if panel:
			panel.visible = (i == target_panel)
			
			# Reset scroll position when showing a panel
			if panel.visible:
				panel.scroll_vertical = 0

# Update button selection visual states
func _update_button_selection(selected_button: TextureButton) -> void:
	for button in buttons:
		if button == selected_button:
			button.select()
		else:
			button.deselect()

# Check if panel number is within valid range
func _is_valid_panel_number(panel_number: int) -> bool:
	return panel_number >= 0 and panel_number < panels.size()
#endregion
