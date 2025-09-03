extends Control
class_name DeckStats

## Deck statistics display component
## Shows current deck size compared to minimum and maximum limits.
## Provides visual feedback when deck reaches size boundaries.

@export var current_deck_size: Label
@export var minimum_deck_size: Label
@export var maximum_deck_size: Label

#region Public Methods
# Update all deck statistics displays
func set_deck_stats(current: int, minimum: int, maximum: int) -> void:
	_update_deck_size_text(current, minimum, maximum)
	_update_visual_feedback(current, minimum, maximum)

# Update the text content of all labels
func _update_deck_size_text(current: int, minimum: int, maximum: int) -> void:
	if current_deck_size:
		current_deck_size.text = DescriptionFormatter.format_deck_count(current, "Cards in your deck.")
	
	if minimum_deck_size:
		minimum_deck_size.text = DescriptionFormatter.format_deck_size_info(minimum, "Min deck size.")
	
	if maximum_deck_size:
		maximum_deck_size.text = DescriptionFormatter.format_deck_size_info(maximum, "Max deck size.")

# Update visual feedback colors based on deck size limits
func _update_visual_feedback(current: int, minimum: int, maximum: int) -> void:
	if not current_deck_size or not current_deck_size.label_settings:
		return
	
	var default_color: Color = current_deck_size.label_settings.font_color
	var warning_color: Color = Color.RED
	
	if maximum_deck_size and maximum_deck_size.label_settings:
		maximum_deck_size.label_settings.font_color = warning_color if current == maximum else default_color
	
	if minimum_deck_size and minimum_deck_size.label_settings:
		minimum_deck_size.label_settings.font_color = warning_color if current == minimum else default_color
#endregion
