extends BaseCardDescription
class_name MajorCardDescription

## Major Arcana card descriptions (IDs 501+)

static func _get_specific_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.major_stats
	
	match card.card_id_num:
		501:
			return _fool_description(bb_formatted)
		502:
			return _magician_description(stats, bb_formatted)
		503:
			return _high_priestess_description(stats, bb_formatted)
		504:
			return _empress_description(stats, bb_formatted)
		505:
			return _emperor_description(stats, bb_formatted)
		_:
			return super._get_specific_description(card, bb_formatted)

static func _fool_description(bb_formatted: bool) -> String:
	return ("Immediately shuffle your deck. You " +
			format_positive_negative("keep", "lose", bb_formatted) +
			" all of your current bonus'.")

static func _magician_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.magician)
	return ("Pick a suit. " + count + " random cards from this suit are " +
			format_positive_negative("added", "removed", bb_formatted) +
			" until your next shuffle.")

static func _high_priestess_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.high_priestess)
	return ("Reveals the next " + count + " cards in your deck without drawing them" +
			" / " +
			"Hides the next " + count + " cards from view until drawn.")

static func _empress_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.empress)
	return ("Remembers the last " + count + " card(s) drawn and then " +
			format_positive_negative("adds", "removes", bb_formatted) +
			" the value from your next card's total. Lasts until your next shuffle.")

static func _emperor_description(stats: MajorStats, bb_formatted: bool) -> String:
	var value = str(stats.emperor)
	return format_positive_negative("Increase", "decrease", bb_formatted) +
			" the base value of your cards by " + value + ". Lasts until your next shuffle."

static func _get_card_title(card: Card) -> String:
	match card.card_id_num:
		501: return "The Fool"
		502: return "The Magician"
		503: return "The High Priestess"
		504: return "The Empress" 
		505: return "The Emperor"
		_: return "Major Arcana"
