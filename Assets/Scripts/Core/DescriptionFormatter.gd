extends RefCounted
class_name DescriptionFormatter

## Card Description Formatting Utility
## Centralizes the repetitive string building patterns for card descriptions

#region Color Tags
const GOOD_COLOR: String = "[color=%#e7c45a]"
const BAD_COLOR: String = "[color=%#ce151e]"
const END_COLOR_TAG: String = "[/color]"
#endregion

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

## Creates error message with context formatting
static func format_error_message(operation: String, details: String) -> String:
	return "%s: %s" % [operation, details]

## Creates percentage display formatting
static func format_percentage(value: float, decimals: int = 1) -> String:
	var format_string = "%.*f%%" % [decimals, value * 100]
	return format_string

## Formats deck statistics text
static func format_deck_count(count: int, label: String) -> String:
	return "%d %s" % [count, label]

## Formats deck size statistics
static func format_deck_size_info(size: int, type_label: String) -> String:
	return "%d: %s" % [size, type_label]

## Formats warning messages for debugging
static func format_warning_message(module: String, message: String) -> String:
	return "%s: %s" % [module, message]
#endregion
static func protected_broken_text(context: String) -> String:
	return GOOD_COLOR + "protected" + END_COLOR_TAG + " / " + BAD_COLOR + "broken" + END_COLOR_TAG + " " + context

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

## Example usage for common card patterns:
## DescriptionFormatter.add_remove_text("1 Cup bank")
## DescriptionFormatter.value_effect_text("5", "5", "to your total") 
## DescriptionFormatter.multiplier_text("2", "the next 3 cards")
