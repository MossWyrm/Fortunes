extends RefCounted
class_name BaseCardDescription

## Base class for card descriptions
## Provides common functionality and template methods

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

# Helper function to convert Color to hex string for BBCode
static func _color_to_hex(color: Color) -> String:
	return "%02x%02x%02x%02x" % [
		int(color.r * 255),
		int(color.g * 255), 
		int(color.b * 255),
		int(color.a * 255)
	]

static func _is_basic_card(card: Card) -> bool:
	return card.id < GameConstants.MAJOR_CARD_THRESHOLD && GameConstants.get_card_value_from_id(card.id) < 11
	
static func get_suit_description(suit: DataStructures.SuitType, bb_formatted: bool = false) -> String:
	match suit:
		DataStructures.SuitType.CUPS:
			if bb_formatted:
				var suit_color = _color_to_hex(DataStructures.core_color.CUPS)
				var good_color = _color_to_hex(DataStructures.core_color.GOOD) 
				var bad_color = _color_to_hex(DataStructures.core_color.BAD)
				return "[color=%s]Cups: [/color][color=%s]Upright[/color]: Add card value to vessels, then gain total vessel contents\n[color=%s]Inverted:[/color] Remove card value from vessels, then gain total vessel contents" % [suit_color, good_color, bad_color]
			else:
				return "Cups: Upright: Add card value to vessels, then gain total vessel contents\nInverted: Remove card value from vessels, then gain total vessel contents"
		
		DataStructures.SuitType.WANDS:
			if bb_formatted:
				var suit_color = _color_to_hex(DataStructures.core_color.WANDS)
				var good_color = _color_to_hex(DataStructures.core_color.GOOD)
				var bad_color = _color_to_hex(DataStructures.core_color.BAD)
				return "[color=%s]Wands: [/color][color=%s]Upright[/color]: Increase wand multiplier by card value, then gain card value × multiplier\n[color=%s]Inverted:[/color] Decrease wand multiplier by card value, then lose card value × multiplier" % [suit_color, good_color, bad_color]
			else:
				return "Wands: Upright: Increase wand multiplier by card value, then gain card value × multiplier\nInverted: Decrease wand multiplier by card value, then lose card value × multiplier"
		
		DataStructures.SuitType.PENTACLES:
			if bb_formatted:
				var suit_color = _color_to_hex(DataStructures.core_color.PENTACLES)
				var good_color = _color_to_hex(DataStructures.core_color.GOOD)
				var bad_color = _color_to_hex(DataStructures.core_color.BAD)
				return "[color=%s]Pentacles: [/color][color=%s]Upright[/color]: Add card value to pentacle protection, then gain card value + protection\n[color=%s]Inverted:[/color] Remove card value from pentacle protection, then gain card value + protection" % [suit_color, good_color, bad_color]
			else:
				return "Pentacles: Upright: Add card value to pentacle protection, then gain card value + protection\nInverted: Remove card value from pentacle protection, then gain card value + protection"
		
		DataStructures.SuitType.SWORDS:
			if bb_formatted:
				var suit_color = _color_to_hex(DataStructures.core_color.SWORDS)
				var good_color = _color_to_hex(DataStructures.core_color.GOOD)
				var bad_color = _color_to_hex(DataStructures.core_color.BAD)
				return "[color=%s]Swords: [/color][color=%s]Upright[/color] / [color=%s]Inverted[/color]: If orientation matches previous sword, increase combo. Gain card value × combo.\nNote: Protection absorbs negative values automatically." % [suit_color, good_color, bad_color]
			else:
				return "Swords: Upright / Inverted: If orientation matches previous sword, increase combo. Gain card value × combo.\nNote: Protection absorbs negative values automatically."
		
		DataStructures.SuitType.MAJOR:
			if bb_formatted:
				var suit_color = _color_to_hex(DataStructures.core_color.MAJOR)
				return "[color=%s]Major Arcana: [/color]Each Major Arcana card has a unique effect that modifies game state, deck composition, or calculation mechanics." % [suit_color]
			else:
				return "Major Arcana: Each Major Arcana card has a unique effect that modifies game state, deck composition, or calculation mechanics."
		
		_:
			return "Unknown suit effect."
#endregion
