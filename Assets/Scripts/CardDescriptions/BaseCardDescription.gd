extends RefCounted
class_name BaseCardDescription

## Base class for card descriptions
## Provides common functionality and template methods

#region Description Building
static func build_description(card: Card, bb_formatted: bool = false) -> Dictionary:
	var output: Dictionary = {}
	var description: String = ""
	
	if _is_basic_card(card):
		description = _get_basic_description()
	else:
		description = _get_specific_description(card, bb_formatted)
	
	output["description"] = description
	output["title"] = _get_card_title(card)
	return output

static func _is_basic_card(card: Card) -> bool:
	return card.card_id_num < GameConstants.MAJOR_CARD_THRESHOLD && GameConstants.get_card_value_from_id(card.card_id_num) < 11

static func _get_basic_description() -> String:
	return "Basic: This card triggers its suit effect and value."

static func _get_specific_description(_card: Card, _bb_formatted: bool) -> String:
	# Override in derived classes
	return "Description not implemented"

static func _get_card_title(_card: Card) -> String:
	# Override in derived classes  
	return "Card"
#endregion

#region Formatting Helpers (Delegate to DescriptionFormatter)
static func format_positive_negative(positive_text: String, negative_text: String, bb_formatted: bool) -> String:
	if not bb_formatted:
		return positive_text + " / " + negative_text
	
	return DescriptionFormatter.good_bad_text(positive_text, negative_text)

static func format_value_effect(good_value: String, bad_value: String, context: String, bb_formatted: bool) -> String:
	if not bb_formatted:
		return "+" + good_value + " / -" + bad_value + " " + context
	
	return DescriptionFormatter.value_effect_text(good_value, bad_value, context)

static func format_add_remove(item: String, bb_formatted: bool) -> String:
	if not bb_formatted:
		return "Add / remove " + item
	
	return DescriptionFormatter.add_remove_text(item)
#endregion
