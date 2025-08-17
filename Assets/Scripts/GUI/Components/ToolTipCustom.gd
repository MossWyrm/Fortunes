@tool
extends RichTextLabel
class_name ToolTipCustom
## Custom tooltip with automatic width management
##
## A RichTextLabel that automatically enables word wrapping when
## it reaches a maximum width threshold, optimizing tooltip display.

#region Properties
# Maximum width before word wrap is enabled
var width_max: int = GameConstants.TOOLTIP_MAX_WIDTH
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect resize signal for width monitoring
func _connect_signals() -> void:
	resized.connect(_on_resized)
#endregion

#region Width Management
# Handle resize events to check width constraints
func _on_resized() -> void:
	_check_width_limit()

# Check if width limit is reached and enable word wrap if needed
func _check_width_limit() -> void:
	if size.x >= width_max:
		_enable_word_wrap()
		_disconnect_resize_signal()

# Enable word wrapping and set minimum size
func _enable_word_wrap() -> void:
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	custom_minimum_size.x = width_max

# Disconnect resize signal after word wrap is enabled
func _disconnect_resize_signal() -> void:
	if resized.is_connected(_on_resized):
		resized.disconnect(_on_resized)
#endregion