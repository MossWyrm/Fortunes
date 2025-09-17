extends RefCounted
class_name DescriptionFormatter

## Card Description Formatting Utility
## Centralizes the repetitive string building patterns for card descriptions

const GOOD_COLOR: String = "[color=#e7c45a]"
const BAD_COLOR: String = "[color=#ce151e]"
const END_COLOR_TAG: String = "[/color]"

## Suit color constants for upgrade display
const SUIT_COLORS: Dictionary = {
	DataStructures.SuitType.CUPS: "[color=#1169be]",
	DataStructures.SuitType.WANDS: "[color=#509600]", 
	DataStructures.SuitType.PENTACLES: "[color=#ce151e]",
	DataStructures.SuitType.SWORDS: "[color=#e2bc10]",
	DataStructures.SuitType.MAJOR: "[color=#a863da]"
}

## Creates the common "Add/Remove" pattern
static func add_remove_text(item: String) -> String:
	return GOOD_COLOR + "Add" + END_COLOR_TAG + " / " + BAD_COLOR + "remove" + END_COLOR_TAG + " " + item

## Creates the common "Increase/Decrease" pattern  
static func increase_decrease_text(item: String) -> String:
	return GOOD_COLOR + "Increase " + END_COLOR_TAG + " / " + BAD_COLOR + "decrease" + END_COLOR_TAG + " " + item

## Creates the common "Positive/Negative" pattern
static func positive_negative_text(context: String) -> String:
	return GOOD_COLOR + "positive" + END_COLOR_TAG + " / " + BAD_COLOR + "negative" + END_COLOR_TAG + " " + context

## Creates custom good/bad text pattern for card descriptions  
static func good_bad_text(good_text: String, bad_text: String) -> String:
	return GOOD_COLOR + good_text + END_COLOR_TAG + " / " + BAD_COLOR + bad_text + END_COLOR_TAG

## Creates the common "Protected/Broken" pattern
static func protected_broken_text(item: String) -> String:
	return GOOD_COLOR + "protected" + END_COLOR_TAG + " / " + BAD_COLOR + "broken" + END_COLOR_TAG + " " + item

## Creates a title-description formatted text block
static func format_title_description(title: String, description: String) -> String:
	return "%s\n%s" % [title, description]

## Creates a title-description formatted text block with purchase count information
static func format_title_description_with_count(title: String, description: String, purchased: int, max_purchases: int = -1) -> String:
	var title_with_count: String
	if max_purchases > 0:
		title_with_count = "%s [%d/%d]" % [title, purchased, max_purchases]
	elif purchased > 0:
		title_with_count = "%s [%d]" % [title, purchased]
	else:
		title_with_count = title
	
	return "%s\n%s" % [title_with_count, description]

## Creates error message with context formatting
static func format_error_message(operation: String, details: String) -> String:
	return "%s: %s" % [operation, details]

## Creates percentage display formatting
static func format_percentage(value: float, decimals: int = 1) -> String:
	var format_string = "%.*f%%" % [decimals, value * 100]
	return format_string
#endregion

## Creates value-based descriptions with color coding
static func value_effect_text(good_value: String, bad_value: String, context: String = "") -> String:
	var result = GOOD_COLOR + "+" + good_value + END_COLOR_TAG + " / " + BAD_COLOR + "-" + bad_value + END_COLOR_TAG
	if context != "":
		result += " " + context
	return result

## Creates multiplier text
static func multiplier_text(multiplier: String, context: String = "") -> String:
	return GOOD_COLOR + "multiply" + END_COLOR_TAG + " / " + BAD_COLOR + "divide" + END_COLOR_TAG + " " + context + " by " + multiplier

## Creates conditional effect text
static func conditional_effect_text(condition: String, good_effect: String, bad_effect: String) -> String:
	return condition + " " + GOOD_COLOR + good_effect + END_COLOR_TAG + " / " + BAD_COLOR + bad_effect + END_COLOR_TAG

## Gets the suit color for an upgrade type
static func get_suit_color_tag(upgrade_type: UpgradeData.UpgradeType) -> String:
	match upgrade_type:
		UpgradeData.UpgradeType.CUPS:
			return SUIT_COLORS[DataStructures.SuitType.CUPS]
		UpgradeData.UpgradeType.WANDS:
			return SUIT_COLORS[DataStructures.SuitType.WANDS]
		UpgradeData.UpgradeType.PENTACLES:
			return SUIT_COLORS[DataStructures.SuitType.PENTACLES]
		UpgradeData.UpgradeType.SWORDS:
			return SUIT_COLORS[DataStructures.SuitType.SWORDS]
		UpgradeData.UpgradeType.MAJOR:
			return SUIT_COLORS[DataStructures.SuitType.MAJOR]
		_:
			return ""  # No color for GENERAL/PACK upgrades

## Applies suit color formatting to upgrade titles
static func format_suit_colored_title(title: String, upgrade_type: UpgradeData.UpgradeType) -> String:
	var color_tag = get_suit_color_tag(upgrade_type)
	if color_tag != "":
		return color_tag + title + END_COLOR_TAG
	return title

## Applies suit color to numerical values in descriptions
static func format_suit_colored_description(description: String, upgrade_type: UpgradeData.UpgradeType, operation_value: float) -> String:
	var color_tag = get_suit_color_tag(upgrade_type)
	if color_tag == "":
		return description
	
	# Convert operation value to appropriate display format
	var value_str: String
	if operation_value == int(operation_value):
		value_str = str(int(operation_value))
	else:
		value_str = "%.2f" % operation_value
	
	# Also handle percentage format for decimal values
	var percent_str = ""
	if operation_value != int(operation_value):
		var percent_val = operation_value * 100
		if percent_val == int(percent_val):
			percent_str = str(int(percent_val)) + "%"
		else:
			percent_str = ("%.1f" % percent_val) + "%"
	
	# Replace numerical values in common patterns with colored versions
	var colored_value = color_tag + value_str + END_COLOR_TAG
	var colored_percent = color_tag + percent_str + END_COLOR_TAG if percent_str != "" else ""
	
	# Replace patterns like "by 1", "+1", "1 more", "25%", etc.
	description = description.replace("by " + value_str, "by " + colored_value)
	description = description.replace("+" + value_str, "+" + colored_value)
	description = description.replace(value_str + " more", colored_value + " more")
	description = description.replace("of " + value_str, "of " + colored_value)
	description = description.replace(value_str + ".", colored_value + ".")
	description = description.replace(value_str + " ", colored_value + " ")
	
	# Handle percentage patterns if applicable
	if colored_percent != "":
		description = description.replace(percent_str, colored_percent)
	
	return description