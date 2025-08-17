extends Node
class_name Tools

# Utility functions for the game, such as formatting numbers and creating tooltips.

## Returns a shorthand string representation of a number, using K for thousands, M for millions, etc.
## [number] : The number to convert.
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


## Returns a TooltipData for the given Card, with correct color and info for display. [br]
## [card] : The Card instance to display in the tooltip.
static func create_card_tooltip(card: Card) -> TooltipData:
	return TooltipData.new(
		card.card_title,
		card.description,
		card,
		DataStructures.core_color.get(DataStructures.SuitType.keys()[card.card_suit], Color.WHITE)
	)

## Returns a TooltipData for a buff, using suit and buff_type to look up the correct Card.
## Works for both suit and major arcana buffs.[br]
## [suit] : DataStructures.SuitType of the buff.[br]
## [buff_type] : The buff type [enum DataStructures.BuffType] for suits, or [enum DataStructures.MAJOR_ID] for majors.[br]
static func create_buff_tooltip(suit: int, buff_type: int) -> TooltipData:
	var card_id: int
	if suit == DataStructures.SuitType.MAJOR:
		card_id = GameConstants.MAJOR_CARD_THRESHOLD + buff_type
	else:
		card_id = GameConstants.calculate_card_id(suit, buff_type)
	var card: Card = GameManager.game_state.deck_manager.get_card(card_id)
	return TooltipData.new(
		card.card_title,
		card.description,
		card,
		DataStructures.core_color.get(DataStructures.SuitType.keys()[card.card_suit], Color.WHITE)
	)