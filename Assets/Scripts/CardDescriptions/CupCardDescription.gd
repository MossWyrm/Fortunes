extends BaseCardDescription
class_name CupCardDescription

## Cup card descriptions (IDs 101-114)

static func get_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.cup_stats
	
	match card.id:
		111:
			return _page_description(stats, bb_formatted)
		112:
			return _knight_description(stats, bb_formatted)
		113:
			return _queen_description(stats, bb_formatted)
		114:
			return _king_description(bb_formatted)
		_:
			# Basic cards (101-110) have no specific effect
			if _is_basic_card(card):
				return "No specific effect."
			return "Description Not Found"

static func get_title(card: Card) -> String:
	match card.id:
		111: return "Page of Cups"
		112: return "Knight of Cups"
		113: return "Queen of Cups"
		114: return "King of Cups"
		_: return str(card.value) + " of Cups"

static func _page_description(stats: CupStats, bb_formatted: bool) -> String:
	var modifier_text = str(stats.page_modifier)
	return ("Multiply your maximum cup size by " + 
			format_positive_negative(modifier_text, modifier_text, bb_formatted) + ".")

static func _knight_description(stats: CupStats, bb_formatted: bool) -> String:
	var count = str(stats.knight_modifier)
	return format_add_remove(count + " random Cup card(s) to / from the deck.", bb_formatted)

static func _queen_description(stats: CupStats, bb_formatted: bool) -> String:
	var count = str(stats.queen_modifier)
	return format_add_remove(count + " Cup bank(s). (You will always have 1 minimum)", bb_formatted)

static func _king_description(bb_formatted: bool) -> String:
	return ("Immediately " + 
			format_positive_negative("Fill", "Empty", bb_formatted) + 
			" all Cup banks.")
