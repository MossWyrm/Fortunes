extends BaseCardDescription
class_name MajorCardDescription

## Major Arcana card descriptions (IDs 501+)

static func get_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.major_stats
	
	match card.id:
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
		506:
			return _hierophant_description(bb_formatted)
		507:
			return _lovers_description(stats, bb_formatted)
		508:
			return _chariot_description(bb_formatted)
		509:
			return _strength_description(stats, bb_formatted)
		510:
			return _hermit_description(bb_formatted)
		511:
			return _wheel_of_fortune_description(stats, bb_formatted)
		512:
			return _justice_description(bb_formatted)
		513:
			return _hanged_man_description()
		514:
			return _death_description(bb_formatted)
		515:
			return _temperance_description(stats, bb_formatted)
		516:
			return _devil_description(stats, bb_formatted)
		517:
			return _tower_description(bb_formatted)
		518:
			return _star_description(stats)
		519:
			return _moon_description(stats, bb_formatted)
		520:
			return _sun_description(stats, bb_formatted)
		521:
			return _judgement_description(stats, bb_formatted)
		522:
			return _world_description()
		_:
			return "Description Not Found"

static func get_title(card: Card) -> String:
	match card.id:
		501: return "The Fool"
		502: return "The Magician"
		503: return "The High Priestess"
		504: return "The Empress" 
		505: return "The Emperor"
		506: return "The Hierophant"
		507: return "The Lovers"
		508: return "The Chariot"
		509: return "Strength"
		510: return "The Hermit"
		511: return "Wheel of Fortune"
		512: return "Justice"
		513: return "The Hanged Man"
		514: return "Death"
		515: return "Temperance"
		516: return "The Devil"
		517: return "The Tower"
		518: return "The Star"
		519: return "The Moon"
		520: return "The Sun"
		521: return "Judgement"
		522: return "The World"
		_: return "Major Arcana"

static func _fool_description(bb_formatted: bool) -> String:
	return ("Immediately shuffle your deck. You " +
			format_positive_negative("keep", "lose", bb_formatted) +
			" all of your current bonus'.")

static func _magician_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.magician)
	return ("Pick a suit. " + count + " random cards from this suit are " +
			format_positive_negative("added", "removed", bb_formatted) +
			" until your next shuffle.")

static func _high_priestess_description(stats: MajorStats, _bb_formatted: bool) -> String:
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
	return format_positive_negative("Increase", "decrease", bb_formatted) + " the base value of your cards by " + value + ". Lasts until your next shuffle."

static func _hierophant_description(bb_formatted: bool) -> String:
	return ("All cards of the same suit as the next drawn card get a " +
			format_positive_negative("bonus multiplier", "penalty", bb_formatted) +
			" until your next shuffle.")

static func _lovers_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.lovers)
	return (format_positive_negative("Copy", "remove", bb_formatted) + 
			" " + count + " " +
			format_positive_negative("cards", "duplicate cards", bb_formatted) +
			" " + format_positive_negative("in", "from", bb_formatted) + 
			" your deck until your next shuffle.")

static func _chariot_description(bb_formatted: bool) -> String:
	return ("If your current card is of higher base value than your previous card, multiply your total by that value." +
			" When you draw a card that's lower, " +
			format_positive_negative("increase", "decrease", bb_formatted) +
			" your Clairvoyance by the total.")

static func _strength_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.strength)
	return ("Convert negative card values to " +
			format_positive_negative("positive", "positive to negative", bb_formatted) +
			" for the next " + count + " cards.")

static func _hermit_description(bb_formatted: bool) -> String:
	return ("If your remaining deck contains no duplicates, " +
			format_positive_negative("double your clairvoyance", "half it", bb_formatted) + ".")

static func _wheel_of_fortune_description(stats: MajorStats, bb_formatted: bool) -> String:
	var charges = str(stats.wheel_charges)
	var mult = str(stats.wheel_mult)
	return ("Pick a suit. If the next card drawn matches that suit, " +
			format_positive_negative("multiply", "divide", bb_formatted) +
			" the next " + charges + " cards by " + mult + ".")

static func _justice_description(bb_formatted: bool) -> String:
	return ("Balance your deck by ensuring " +
			format_positive_negative("equal numbers of each suit", "removing cards from the most common suit", bb_formatted) + ".")

static func _hanged_man_description() -> String:
	return "Currently Unavailable"

static func _death_description(bb_formatted: bool) -> String:
	return ("Transform all cards in your deck to a " +
			format_positive_negative("random suit", "remove all cards of a specific suit", bb_formatted) + ".")

static func _temperance_description(stats: MajorStats, bb_formatted: bool) -> String:
	var value = str(stats.temperance)
	return ("All cards will score a " +
			format_positive_negative("minimum", "maximum", bb_formatted) +
			" of " + value + " until your next shuffle.")

static func _devil_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.devil)
	return ("Adds another Devil to your deck. You " +
			format_positive_negative("may", "must", bb_formatted) +
			" skip " + count + " cards.")

static func _tower_description(bb_formatted: bool) -> String:
	return ("Adds another tower to your deck. " +
			format_positive_negative("Double", "half", bb_formatted) +
			" your cards value. Swap this effect when the other tower is drawn. Resets on your next shuffle.")

static func _star_description(stats: MajorStats) -> String:
	var value = str(stats.star)
	return ("Adds " + value + " to the base value of all positive cards. Can be affected by The Moon. Lasts until your next shuffle")

static func _moon_description(stats: MajorStats, bb_formatted: bool) -> String:
	var mult = str(stats.moon)
	return (format_positive_negative("Multiply star value by " + mult, "Stars now work on negative cards", bb_formatted) +
			" until your next shuffle")

static func _sun_description(stats: MajorStats, bb_formatted: bool) -> String:
	var star_count = str(stats.sun_star)
	var moon_count = str(stats.sun_moon)
	return (format_positive_negative("Add " + star_count + " of The Star and " + moon_count + " of The Moon to your deck", 
			"remove all copies of The Star and The Moon from your deck", bb_formatted) +
			" until your next shuffle.")

static func _judgement_description(stats: MajorStats, bb_formatted: bool) -> String:
	var mult = str(stats.judgement)
	return ("Judgement " + format_positive_negative("multiplies", "divides", bb_formatted) +
			" the value of every card by " + mult + " until your next shuffle.")

static func _world_description() -> String:
	return "The Tower completes the full Arcana, resetting your Tarot Progress and giving you a Deck to spend."