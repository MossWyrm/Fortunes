extends BaseCardDescription
class_name WandCardDescription

## Wand card descriptions (IDs 211-214)

static func _get_specific_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.wand_stats
	
	match card.card_id_num:
		211:
			return _page_description(stats, bb_formatted)
		212:
			return _knight_description(bb_formatted)
		213:
			return _queen_description(stats, bb_formatted)
		214:
			return _king_description(stats, bb_formatted)
		_:
			return super._get_specific_description(card, bb_formatted)

static func _page_description(stats: WandStats, bb_formatted: bool) -> String:
	var modifier = str(stats.page_modifier)
	return ("Next drawn Wand card triggers " +
			format_positive_negative(modifier, "0", bb_formatted) +
			" times.")

static func _knight_description(bb_formatted: bool) -> String:
	return ("Next drawn card (any suit) is " +
			format_positive_negative("Multiplied", "Divided", bb_formatted) +
			" by your Wand strength.")

static func _queen_description(stats: WandStats, bb_formatted: bool) -> String:
	var modifier = str(stats.queen_modifier)
	return ("All Wand values are " +
			format_positive_negative("Increased", "Decreased", bb_formatted) +
			" by " + modifier + ". Lasts until your next shuffle.")

static func _king_description(stats: WandStats, bb_formatted: bool) -> String:
	var modifier = str(stats.king_modifier)
	var divisor = "1/" + modifier
	return ("All your card values are multiplied by " +
			format_positive_negative(modifier, divisor, bb_formatted) +
			".")

static func _get_card_title(card: Card) -> String:
	match card.card_id_num:
		211: return "Wand Page"
		212: return "Wand Knight"
		213: return "Wand Queen"
		214: return "Wand King"
		_: return "Wand Card"
