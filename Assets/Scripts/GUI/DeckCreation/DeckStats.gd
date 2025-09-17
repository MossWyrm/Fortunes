extends Control
class_name DeckStats

## Deck statistics display component
## Shows current deck size compared to minimum and maximum limits.
## Provides visual feedback when deck reaches size boundaries.

@export var current_deck_size: Label
@export var minimum_deck_size: Label
@export var maximum_deck_size: Label
@export var status_message: Label
@export var close_button: Button

#region Public Methods
# Update all deck statistics displays with validation
func set_deck_stats(current: int, minimum: int, maximum: int) -> void:
	_update_deck_size_text(current, minimum, maximum)
	_update_visual_feedback(current, minimum, maximum)
	_update_status_message(current, minimum, maximum)
	_update_close_button_state(current, minimum, maximum)

# Update the text content of all labels with clearer instructions
func _update_deck_size_text(current: int, minimum: int, maximum: int) -> void:
	if current_deck_size:
		current_deck_size.text = str(current)
	
	if minimum_deck_size:
		minimum_deck_size.text = str("MIN\n%d" % minimum)

	if maximum_deck_size:
		maximum_deck_size.text = str("MAX\n%d" % maximum)

# Update visual feedback colors based on deck size validity
func _update_visual_feedback(current: int, minimum: int, maximum: int) -> void:
	if not current_deck_size or not current_deck_size.label_settings:
		return
	
	var default_color: Color = Color.WHITE
	var warning_color: Color = DataStructures.core_color.BAD
	var valid_color: Color = DataStructures.core_color.GOOD
	
	# Current deck size color based on validity
	var current_color = default_color
	if current < minimum or current > maximum:
		current_color = warning_color
	elif current >= minimum and current <= maximum:
		current_color = valid_color
	
	current_deck_size.label_settings.font_color = current_color
	
	# Min/Max colors based on boundaries
	if minimum_deck_size and minimum_deck_size.label_settings:
		minimum_deck_size.label_settings.font_color = warning_color if current < minimum else default_color
	
	if maximum_deck_size and maximum_deck_size.label_settings:
		maximum_deck_size.label_settings.font_color = warning_color if current > maximum else default_color

# Update status message with clear instructions
func _update_status_message(current: int, minimum: int, maximum: int) -> void:
	if not status_message:
		return
	
	var message = ""
	var color = Color.WHITE
	
	if current < minimum:
		var needed = minimum - current
		message = "Add %d more card%s to continue" % [needed, "s" if needed != 1 else ""]
		color = Color.RED
	elif current > maximum:
		var excess = current - maximum
		message = "Remove %d card%s to continue" % [excess, "s" if excess != 1 else ""]
		color = Color.RED
	else:
		message = "Deck is ready!"
		color = Color.GREEN
	
	status_message.text = message
	if status_message.label_settings:
		status_message.label_settings.font_color = color

# Control close button availability
func _update_close_button_state(current: int, minimum: int, maximum: int) -> void:
	if not close_button:
		return
	
	var is_valid = current >= minimum and current <= maximum
	close_button.disabled = not is_valid
	
	if is_valid:
		close_button.text = "Save Deck"
	else:
		close_button.text = "Invalid"

# Public method to check if deck can be closed
func is_deck_valid(current: int, minimum: int, maximum: int) -> bool:
	return current >= minimum and current <= maximum
#endregion
