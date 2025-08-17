extends Node
## Upgrades controller for managing the upgrade shop interface
##
## Handles the display and navigation of different upgrade categories,
## managing upgrade buttons and integrating with the new EventBus architecture.

#region Node References
@onready var upgrade_buttons: Array[Node] = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/UpgradeDisplay/MarginContainer/UpgradeButtons.get_children()
@onready var pack_button: TextureButton = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/Navigation/PackButton
@export var category_buttons: Array[TextureButton] = []
#endregion

#region Properties
var upgrade_manager: UpgradeManager
var current_category: UpgradeData.UpgradeType = UpgradeData.UpgradeType.GENERAL
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_layout()
	_setup_upgrades()

# Connect to event bus and other signals
func _connect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(GameManager.game_state.event_bus.game_reset, _on_game_reset, "UpgradesController game reset")
	
	SignalManager.safe_connect(get_viewport().size_changed, _on_viewport_size_changed, "UpgradesController viewport")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(GameManager.game_state.event_bus.game_reset, _on_game_reset, "UpgradesController game reset")
	
	SignalManager.safe_disconnect(get_viewport().size_changed, _on_viewport_size_changed, "UpgradesController viewport")
#endregion
# Initialize layout and positioning
func _initialize_layout() -> void:
	_update_position()

# Setup initial upgrade display
func _setup_upgrades() -> void:
	if ValidationUtils.has_upgrade_manager():
		upgrade_manager = GameManager.game_state.upgrade_manager
		display_upgrades_for_category()
#endregion

#region Layout Management
# Handle viewport size changes
func _on_viewport_size_changed() -> void:
	_update_position()

# Update panel position
func _update_position() -> void:
	position.x = 0
#endregion

#region Upgrade Display Management
# Display upgrades for a specific category
func display_upgrades_for_category(type: UpgradeData.UpgradeType = UpgradeData.UpgradeType.GENERAL, texture_button: TextureButton = null) -> void:
	if not upgrade_manager:
		push_error("UpgradesController: No upgrade manager available")
		return
	
	var upgrades: Dictionary = upgrade_manager.get_upgrades_for_type(type)
	
	# Check if we have enough upgrade buttons
	if upgrade_buttons.size() < upgrades.size():
		push_error("UpgradesController: Not enough upgrade containers for category")
		return
	
	current_category = type
	
	# Update upgrade buttons with new data
	_update_upgrade_buttons(upgrades)
	
	# Update category button selection
	if texture_button:
		_update_category_selection(texture_button)

# Update individual upgrade buttons
func _update_upgrade_buttons(upgrades: Dictionary) -> void:
	var upgrade_keys: Array = upgrades.keys()
	
	# Show and configure visible buttons
	for i in upgrades.size():
		if i < upgrade_buttons.size():
			var upgrade_data: UpgradeData = upgrades[upgrade_keys[i]]
			upgrade_buttons[i].setup_upgrade(upgrade_data, current_category)
			upgrade_buttons[i].visible = true
	
	# Hide unused buttons
	for i in range(upgrades.size(), upgrade_buttons.size()):
		upgrade_buttons[i].visible = false

# Update category button selection visual feedback
func _update_category_selection(selected_button: TextureButton) -> void:
	for button in category_buttons:
		if button == selected_button:
			button.select()
		else:
			button.deselect()
#endregion

#region Event Handlers
# Handle game reset events
func _on_game_reset() -> void:
	current_category = UpgradeData.UpgradeType.GENERAL
	if upgrade_manager:
		display_upgrades_for_category()
#endregion
				
func on_toggle_visible() -> void:
	if self.visible:
		set_upgrades(last_opened)
		if Stats.packs > 0 && !pack_button.is_visible():
			pack_button.show()
		
func save() -> Dictionary:
	var save_file: Dictionary = {}
	var upgrades: Dictionary  = upgrade_options.get_full_list()
	for key in upgrades.keys():
		var suit_collection: Dictionary = {}
		for upgrade in upgrades[key].keys():
			suit_collection[upgrade] = upgrades[key][upgrade].times_purchased
		save_file[key] = suit_collection
	return save_file
	
func load_upgrades(dict: Dictionary) -> void:
	var upgrades: Dictionary = upgrade_options.get_full_list()
	if upgrades == null:
		print("Upgrades list not found")
		return
	for suit in dict.keys():
		for title in dict[suit].keys():
			upgrades[int(suit)][title].times_purchased = dict[suit][title]
		
func reset_upgrades(type: DataStructures.GameLayer) -> void:
	upgrade_options.reset(type)