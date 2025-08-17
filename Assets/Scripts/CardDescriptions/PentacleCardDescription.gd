extends BaseCardDescription
class_name PentacleCardDescription

## Pentacle card descriptions (IDs 311-314)

static func _get_specific_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.pentacle_stats
	
	match card.card_id_num:
		311:
			return _page_description(stats, bb_formatted)
		312:
			return _knight_description(stats, bb_formatted)
		313:
			return _queen_description(stats, bb_formatted)
		314:
			return _king_description(stats, bb_formatted)
		_:
			return super._get_specific_description(card, bb_formatted)

static func _page_description(stats: PentacleStats, bb_formatted: bool) -> String:
	var modifier = str(stats.page_modifier)
	var divisor = "1/" + modifier
	return ("Your Protection is multiplied by " +
			format_positive_negative(modifier, divisor, bb_formatted) +
			".")

static func _knight_description(stats: PentacleStats, bb_formatted: bool) -> String:
	var uses = str(stats.knight_uses)
	return ("Your Protection is " +
			format_positive_negative("given " + uses + " extra uses", "cleared", bb_formatted) +
			".")

static func _queen_description(stats: PentacleStats, bb_formatted: bool) -> String:
	var uses = str(stats.queen_uses)
	return ("Flips your next " + uses + " card(s) " +
			format_positive_negative("positive", "negative", bb_formatted) +
			".")

static func _king_description(stats: PentacleStats, bb_formatted: bool) -> String:
	var uses = str(stats.king_uses)
	var value = str(stats.king_value)
	return ("Your Protection uses are set to " + uses + " and it gains " +
			format_positive_negative("+" + value, "-" + value, bb_formatted) +
			" base value.")

static func _get_card_title(card: Card) -> String:
	match card.card_id_num:
		311: return "Pentacle Page"
		312: return "Pentacle Knight"
		313: return "Pentacle Queen"
		314: return "Pentacle King"
		_: return "Pentacle Card"
