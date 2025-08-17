extends Control
class_name CardSelectBoxList
## Container for managing multiple card selection display boxes
##
## Simple collection manager that holds references to card selection display boxes
## for easy access and management across the card selection interface.

#region Properties
@export var displays_list: Array[CardSelectDisplayBox]
#endregion

#region Public Methods
# Get the number of display boxes in the list
func get_display_count() -> int:
	return displays_list.size()

# Get a specific display box by index
func get_display(index: int) -> CardSelectDisplayBox:
	if index >= 0 and index < displays_list.size():
		return displays_list[index]
	return null

# Add a display box to the list
func add_display(display: CardSelectDisplayBox) -> void:
	if display and display not in displays_list:
		displays_list.append(display)

# Remove a display box from the list
func remove_display(display: CardSelectDisplayBox) -> void:
	displays_list.erase(display)

# Clear all display boxes
func clear_displays() -> void:
	displays_list.clear()
#endregion
