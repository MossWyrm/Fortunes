extends TextureButton
class_name UpgradesSelectButton
## Upgrade category selection button
##
## Button for switching between different upgrade categories in the upgrade shop.
## Provides visual feedback when selected and plays sound effects.

#region Export Properties
@export var upgrade_controller: UpgradesController
@export var upgrade_type: UpgradeData.UpgradeType
#endregion

#region Node References
@onready var border: ColorRect = $MASK/ColorRect
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button signals
func _connect_signals() -> void:
	SignalManager.safe_connect(pressed, _on_button_pressed, "UpgradesSelectButton pressed")

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	SignalManager.safe_disconnect(pressed, _on_button_pressed, "UpgradesSelectButton pressed")
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
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.sfx_requested.emit(DataStructures.SFXType.MENU_TAP)
#endregion

#region Visual State Management
# Show selection border
func select() -> void:
	if border:
		border.show()

# Hide selection border
func deselect() -> void:
	if border:
		border.hide()
#endregion
