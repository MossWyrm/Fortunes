extends Control
class_name UpgradesController

## Upgrades controller for managing the upgrade shop interface
## Handles the display and navigation of different upgrade categories,
## managing upgrade buttons and integrating with the EventBus architecture.

@onready var upgrade_buttons_container: VBoxContainer = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/UpgradeDisplay/MarginContainer/UpgradeButtons
@onready var pack_button: TextureButton = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/Navigation/PackButton
@export var category_buttons: Array[TextureButton] = []

# Dynamic button management
var upgrade_button_scene: PackedScene = preload("res://Assets/upgrade_button.tscn")
var upgrade_buttons: Array[Control] = []  # Fixed ordered array of upgrade buttons

var upgrade_manager: UpgradeManager
var current_category: UpgradeData.UpgradeType = UpgradeData.UpgradeType.GENERAL

#region Initialization
func _ready() -> void:
	_connect_signals()
	_setup_upgrades()
	GameManager.game_state.nav_manager.upgrade_panel = self

# Connect to event bus and other signals
func _connect_signals() -> void:
	EventBus.currency_updated.connect(_on_currency_updated)
	EventBus.upgrade_purchased.connect(_on_upgrade_purchased)
	EventBus.game_loaded.connect(_on_game_loaded)
	visibility_changed.connect(_on_toggle_visible)

# Setup initial upgrade display
func _setup_upgrades() -> void:
	DebugManager.print_upgrades_system("UpgradesController: Setting up upgrade display system")
	_initialize_dynamic_buttons()  # Initialize the dynamic button system
	if ValidationUtils.has_upgrade_manager():
		upgrade_manager = GameManager.game_state.upgrade_manager
		DebugManager.print_upgrades_system("UpgradesController: Connected to UpgradeManager, displaying default category")
		display_upgrades_for_category()
	else:
		DebugManager.print_upgrades_system("UpgradesController: No UpgradeManager available", DebugManager.DebugLevel.WARNING)
#endregion

#region Upgrade Display Management
# Display upgrades for a specific category
func display_upgrades_for_category(type: UpgradeData.UpgradeType = UpgradeData.UpgradeType.GENERAL, texture_button: TextureButton = null) -> void:
	DebugManager.print_upgrades_system("UpgradesController: Displaying upgrades for category %s" % str(type))
	
	if not upgrade_manager:
		DebugManager.print_upgrades_system("UpgradesController: No upgrade manager available", DebugManager.DebugLevel.ERROR)
		return
		
	var upgrades: Dictionary = upgrade_manager.get_upgrades_for_type(type)
	current_category = type
	var display_data = UpgradeDisplayData.create_batch(upgrades, upgrade_manager)
	
	DebugManager.print_upgrades_system("UpgradesController: Created display data for %d upgrades in category %s" % [display_data.size(), str(type)])
	
	_update_buttons_with_data(display_data)
	if texture_button:
		_update_category_selection(texture_button)

	update_category_availability_indicators()

# Update buttons with complete display data using ordered array
func _update_buttons_with_data(display_data_list: Array[UpgradeDisplayData]) -> void:

	
	# Ensure we have enough buttons
	_ensure_button_capacity(display_data_list.size())
	
	# Hide all buttons first
	_hide_all_buttons()
	
	# Show and populate only the buttons we need, in order
	for i in range(display_data_list.size()):
		if display_data_list[i] and i < upgrade_buttons.size():
			var button = upgrade_buttons[i]
			button.display(display_data_list[i])
			button.show()
	


# Refresh all visible upgrade buttons (called on currency/purchase events)
func refresh_upgrade_displays() -> void:
	if current_category == null:
		return
	display_upgrades_for_category(current_category)

# Update category button selection visual feedback
func _update_category_selection(selected_button: TextureButton) -> void:
	for button in category_buttons:
		if button == selected_button:
			button.select()
		else:
			button.deselect()
#endregion

#region Dynamic Button Management
# Hide all buttons in the ordered array
func _hide_all_buttons() -> void:
	for button in upgrade_buttons:
		button.hide()

# Ensure we have enough buttons in the ordered array
func _ensure_button_capacity(required_count: int) -> void:
	var buttons_needed = required_count - upgrade_buttons.size()
	
	if buttons_needed > 0:
		
		for i in range(buttons_needed):
			_create_new_button()

# Create a new upgrade button and add it to the ordered array
func _create_new_button() -> void:
	var new_button = upgrade_button_scene.instantiate()
	upgrade_buttons_container.add_child(new_button)
	new_button.hide()  # Start hidden
	upgrade_buttons.append(new_button)

# Initialize the button system with a fixed ordered array
func _initialize_dynamic_buttons() -> void:
	DebugManager.print_upgrades_system("UpgradesController: Initializing ordered button system")
	
	# Remove any existing static buttons from the scene
	var existing_children = upgrade_buttons_container.get_children().size()
	for child in upgrade_buttons_container.get_children():
		child.queue_free()
	
	# Clear the button array
	upgrade_buttons.clear()
	
	DebugManager.print_upgrades_system("UpgradesController: Removed %d existing buttons, creating ordered button array" % existing_children)

# Get statistics about button usage (for debugging/optimization)
func get_button_stats() -> Dictionary:
	var visible_count = 0
	for button in upgrade_buttons:
		if button.visible:
			visible_count += 1
	
	return {
		"total_buttons": upgrade_buttons.size(),
		"visible_buttons": visible_count,
		"hidden_buttons": upgrade_buttons.size() - visible_count,
		"container_children": upgrade_buttons_container.get_child_count()
	}
#endregion

#region Event Handlers
# Handle currency updates to refresh availability indicators
func _on_currency_updated(_amount: int, _type: DataStructures.CurrencyType) -> void:

	update_category_availability_indicators()
	refresh_upgrade_displays()  # Refresh all visible upgrade displays

# Handle upgrade purchases to refresh displays (especially for 0-cost upgrades)
func _on_upgrade_purchased(_upgrade: UpgradeData) -> void:
	DebugManager.print_upgrades_system("UpgradesController: Upgrade '%s' purchased, refreshing UI displays" % _upgrade.id)
	update_category_availability_indicators()
	refresh_upgrade_displays()  # Refresh to show new costs after purchase

# Handle game loaded event to refresh UI
func _on_game_loaded() -> void:
	_setup_upgrades()
	update_category_availability_indicators()

# Refresh upgrades when visibility changes
func _on_toggle_visible() -> void:
	if self.visible and current_category != null:
		display_upgrades_for_category(current_category)
		if GameManager.game_state.stats.packs > 0 and not pack_button.is_visible():
			pack_button.show()
		update_category_availability_indicators()
#endregion

# Get upgrade statistics for the current category
func get_category_upgrade_stats() -> Dictionary:
	if not upgrade_manager:
		return {}
	
	var upgrades: Dictionary = upgrade_manager.get_upgrades_for_type(current_category)
	var stats: Dictionary = {
		"total_upgrades": upgrades.size(),
		"purchased_upgrades": 0,
		"maxed_upgrades": 0,
		"total_spent": 0.0,
		"upgrades_available": 0
	}
	
	for upgrade_id in upgrades.keys():
		var upgrade_progress = upgrade_manager.get_upgrade_progress(upgrade_id)
		if upgrade_progress.get("current_purchases", 0) > 0:
			stats.purchased_upgrades += 1
		
		if upgrade_progress.get("is_maxed", false):
			stats.maxed_upgrades += 1
		
		if upgrade_progress.get("can_afford", false) and not upgrade_progress.get("is_maxed", false):
			stats.upgrades_available += 1
	
	return stats

# Get detailed progress for all upgrades in current category
func get_all_upgrade_progress() -> Dictionary:
	if not upgrade_manager:
		return {}
	
	var upgrades: Dictionary = upgrade_manager.get_upgrades_for_type(current_category)
	var progress_data: Dictionary = {}
	
	for upgrade_id in upgrades.keys():
		progress_data[upgrade_id] = upgrade_manager.get_upgrade_progress(upgrade_id)
	
	return progress_data
#endregion

# Update availability indicators on all category buttons
func update_category_availability_indicators() -> void:
	if not upgrade_manager:
		DebugManager.print_upgrades_system("UpgradesController: Cannot update availability indicators - no upgrade manager", DebugManager.DebugLevel.WARNING)
		return
	

	
	# Update all category select buttons with pre-calculated data
	for button in category_buttons:
		# DEBUG: Let's see what type these buttons actually are

		
		if button is UpgradesSelectNavButton:
			var has_affordable = upgrade_manager.has_affordable_upgrades(button.upgrade_type)

			button.update_availability_indicator(has_affordable)
		else:
			DebugManager.print_upgrades_system("UpgradesController: Button is not UpgradesSelectNavButton, skipping indicator update", DebugManager.DebugLevel.WARNING)