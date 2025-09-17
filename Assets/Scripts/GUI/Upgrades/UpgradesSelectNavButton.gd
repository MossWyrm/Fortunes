extends TextureButton
class_name UpgradesSelectNavButton

## Upgrade category selection button
## Button for switching between different upgrade categories in the upgrade shop.
## Provides visual feedback when selected and plays sound effects.

@export var upgrade_controller: UpgradesController
@export var upgrade_type: UpgradeData.UpgradeType

@onready var border: ColorRect = $MASK/ColorRect

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button signals
func _connect_signals() -> void:
	pressed.connect(_on_button_pressed)
#endregion

#region Input Handling
# Handle button press and switch upgrade category
func _on_button_pressed() -> void:
	_select_upgrade_panel()
	_play_menu_sound()

# Switch to this button's upgrade category
func _select_upgrade_panel() -> void:
	if upgrade_controller:
		upgrade_controller.display_upgrades_for_category(upgrade_type, self)

# Play menu tap sound effect
func _play_menu_sound() -> void:
	# Direct EventBus access - always available as autoload
	EventBus.emit_sfx_requested(DataStructures.SFXType.MENU_TAP)
#endregion

#region Visual State Management
# Show selection border and scale up
func select() -> void:
	if border:
		border.show()
	scale = Vector2(1.1, 1.1)  # 10% larger when selected

# Hide selection border and return to normal size
func deselect() -> void:
	if border:
		border.hide()
	scale = Vector2(1.0, 1.0)  # Normal size when deselected

# Update availability indicator (called by controller with pre-calculated data)
func update_availability_indicator(has_affordable: bool) -> void:
	# Add visual indicator for affordable upgrades
	if has_affordable:
		modulate = Color.WHITE  # Normal color
	else:
		modulate = Color(0.7, 0.7, 0.7)  # Dimmed when no affordable upgrades
#endregion
