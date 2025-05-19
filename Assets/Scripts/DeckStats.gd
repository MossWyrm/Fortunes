extends Control
class_name DeckStats


@export var current_deck_size: Label
@export var minimum_deck_size: Label
@export var maximum_deck_size: Label

func set_deck_stats(current, minimum, maximum):
	current_deck_size.text = str(current) + " Cards in your deck."
	minimum_deck_size.text = str(minimum) + ": Min deck size."
	maximum_deck_size.text = str(maximum) + ": Max deck size."
	if current == maximum:
		maximum_deck_size.label_settings.font_color = Color.RED
	else:
		maximum_deck_size.label_settings.font_color = current_deck_size.label_settings.font_color
	if current == minimum:
		minimum_deck_size.label_settings.font_color = Color.RED
	else:
		minimum_deck_size.label_settings.font_color = current_deck_size.label_settings.font_color
