extends Control
class_name UpgradesController

## Upgrades controller for managing the upgrade shop interface
## Handles the display and navigation of different upgrade categories,
## managing upgrade buttons and integrating with the EventBus architecture.

@onready var upgrade_buttons: Array[Node] = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/UpgradeDisplay/MarginContainer/UpgradeButtons.get_children()
@onready var pack_button: TextureButton = $MarginContainer/UpgradePanel/Control/MarginContainer/VBox/Navigation/PackButton
@export var category_buttons: Array[TextureButton] = []

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
	visibility_changed.connect(on_toggle_visible)

# Setup initial upgrade display
func _setup_upgrades() -> void:
	if ValidationUtils.has_upgrade_manager():
		upgrade_manager = GameManager.game_state.upgrade_manager
		display_upgrades_for_category()
#endregion

#region Upgrade Display Management
# Display upgrades for a specific category
func display_upgrades_for_category(type: UpgradeData.UpgradeType = UpgradeData.UpgradeType.GENERAL, texture_button: TextureButton = null) -> void:
	if not upgrade_manager:
		push_error("UpgradesController: No upgrade manager available")
		return
	var upgrades: Dictionary = upgrade_manager.get_upgrades_for_type(type)
	current_category = type
	var display_data = UpgradeDisplayData.create_batch(upgrades, upgrade_manager)
	_update_buttons_with_data(display_data)
	if texture_button:
		_update_category_selection(texture_button)

# Update buttons with complete display data
func _update_buttons_with_data(display_data_list: Array[UpgradeDisplayData]) -> void:
	for i in range(upgrade_buttons.size()):
		var button = upgrade_buttons[i]
		if i < display_data_list.size() and display_data_list[i]:
			button.show()
			button.display(display_data_list[i])
		else:
			button.hide()

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

#region Event Handlers
# Handle currency updates to refresh availability indicators
func _on_currency_updated(_amount: int, _type: DataStructures.CurrencyType) -> void:
	update_category_availability_indicators()
	refresh_upgrade_displays()  # Refresh all visible upgrade displays

# Handle upgrade purchases to refresh displays (especially for 0-cost upgrades)
func _on_upgrade_purchased(_upgrade: UpgradeData) -> void:
	update_category_availability_indicators()
	refresh_upgrade_displays()  # Refresh to show new costs after purchase

# Handle game loaded event to refresh UI
func _on_game_loaded() -> void:
	_setup_upgrades()
	update_category_availability_indicators()

# Refresh upgrades when visibility changes
func on_toggle_visible() -> void:
	if self.visible and current_category != null:
		display_upgrades_for_category(current_category)
		if GameManager.game_state.stats.packs > 0 and not pack_button.is_visible():
			pack_button.show()
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

# Update availability indicators on all category buttons
func update_category_availability_indicators() -> void:
	if not upgrade_manager:
		return
	
	# Update all category select buttons with pre-calculated data
	for button in category_buttons:
		if button is UpgradesSelectNavButton:
			var has_affordable = upgrade_manager.has_affordable_upgrades(button.upgrade_type)
			button.update_availability_indicator(has_affordable)


#endregion