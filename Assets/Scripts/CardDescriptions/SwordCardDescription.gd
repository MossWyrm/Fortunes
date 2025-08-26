extends BaseCardDescription
class_name SwordCardDescription

## Sword card descriptions (IDs 401-414)

static func get_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.sword_stats
	
	match card.id:
		411:
			return _page_description(stats, bb_formatted)
		412:
			return _knight_description(stats, bb_formatted)
		413:
			return _queen_description(stats, bb_formatted)
		414:
			return _king_description(stats, bb_formatted)
		_:
			# Basic cards (401-410) have no specific effect
			if _is_basic_card(card):
				return "No specific effect."
			return "No Description Found"

static func get_title(card: Card) -> String:
	match card.id:
		411: return "Page of Swords"
		412: return "Knight of Swords"
		413: return "Queen of Swords"
		414: return "King of Swords"
		_: return str(card.value) + " of Swords"

static func _page_description(stats: SwordStats, bb_formatted: bool) -> String:
	var _modifier = str(stats.page_modifier)
	return ("Next sword card is raised to the power of your Combo, and then " +
			format_positive_negative("Added", "Subtracted", bb_formatted) +
			" from your total.")

static func _knight_description(stats: SwordStats, bb_formatted: bool) -> String:
	var modifier = str(stats.knight_modifier)
	var super_text = "" if stats.knight_super else "not "
	return (format_positive_negative("Add", "Remove", bb_formatted) +
			" 1 random unlocked card below " + modifier + " (" + super_text + "including majors) for each combo point you have.")

static func _queen_description(stats: SwordStats, bb_formatted: bool) -> String:
	var modifier = str(stats.queen_modifier)
	return ("Each Combo point is worth" +
			format_value_effect(modifier, modifier, ".", bb_formatted))

static func _king_description(stats: SwordStats, bb_formatted: bool) -> String:
	var modifier = str(stats.king_modifier)
	return ("Your Combo is " +
			format_positive_negative("protected", "broken", bb_formatted) +
			" the next " + modifier + " times it would otherwise be " +
			format_positive_negative("decreased", "increased", bb_formatted) +
			".")