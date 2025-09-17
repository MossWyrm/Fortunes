extends RefCounted
class_name Tools

# Utility functions for the game, such as formatting numbers and creating tooltips.

## Returns a shorthand string representation of a number, using K for thousands, M for millions, etc.
static func get_shorthand(number: int) -> String:
	if number < GameConstants.NUMBER_FORMAT_THRESHOLD:
		return str(number)
	var suffix: Array     = ["K","M","B","T","Qa","Qi","Sx","Se","Oc","No"]
	var suffix_index: int = -1
	var numfloat: float   = float(number)
	while numfloat >= GameConstants.NUMBER_FORMAT_DIVISOR:
		suffix_index += 1
		numfloat /= GameConstants.NUMBER_FORMAT_DIVISOR
	
	var output_num: String
	if numfloat >= GameConstants.LARGE_NUMBER_THRESHOLD || numfloat == 0:
		output_num = str("%d" % numfloat)
	elif numfloat < GameConstants.LARGE_NUMBER_THRESHOLD && numfloat > GameConstants.MEDIUM_NUMBER_THRESHOLD:
		output_num = str("%.1f" % numfloat)
	else:
		output_num = str("%.2f" % numfloat)
	
	return str("%s%s"%[output_num, suffix[suffix_index]])

#region Card Description Tools
static func get_card_title(card: Card) -> String:
	if not card:
		return "Unknown Card"
	return CardDescriptionFactory.get_description(card).get("title", "No Title available")

static func get_card_description(card: Card, bb_formatted: bool = false) -> String:
	if not card:
		return "Unknown card description"
	return CardDescriptionFactory.get_description(card, bb_formatted).get("card", "No description available")

static func get_suit_description(card: Card, bb_formatted: bool = false) -> String:
	if not card:
		return "Unknown suit description"
	return CardDescriptionFactory.get_description(card, bb_formatted).get("suit", "No suit description available")

static func get_suit_description_by_type(suit: DataStructures.SuitType, bb_formatted: bool = false) -> String:
	return CardDescriptionFactory.get_suit_description(suit, bb_formatted)
#endregion

## Creates a buff tooltip by looking up the card from suit and buff_type.[br]
## Returns the Card object for tooltip display, or null if not found.[br]
## [suit] : DataStructures.SuitType of the buff.[br]
## [buff_type] : The buff type [enum DataStructures.BuffType] for suits, or [enum DataStructures.MAJOR_ID] for majors.[br]
static func get_buff_card(suit: int, buff_type: int) -> Card:
	var card_id: int
	if suit == DataStructures.SuitType.MAJOR:
		card_id = GameConstants.MAJOR_CARD_THRESHOLD + buff_type + 1
	else:
		card_id = GameConstants.calculate_card_id(suit, buff_type)
	
	if ValidationUtils.has_deck_manager():
		return GameManager.game_state.deck_manager.get_card(card_id)
	
	return null