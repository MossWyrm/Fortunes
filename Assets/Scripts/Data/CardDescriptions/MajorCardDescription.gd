extends BaseCardDescription
class_name MajorCardDescription

## Major Arcana card descriptions (IDs 501+)

static func get_description(card: Card, bb_formatted: bool) -> String:
	var stats = GameManager.game_state.stats.major_stats
	
	match card.id:
		501: return _fool_description(bb_formatted)
		502: return _magician_description(stats, bb_formatted)
		503: return _high_priestess_description(stats, bb_formatted)
		504: return _empress_description(stats, bb_formatted)
		505: return _emperor_description(stats, bb_formatted)
		506: return _hierophant_description(stats, bb_formatted)
		507: return _lovers_description(stats, bb_formatted)
		508: return _chariot_description(bb_formatted)
		509: return _strength_description(stats, bb_formatted)
		510: return _hermit_description(bb_formatted)
		511: return _wheel_of_fortune_description(stats, bb_formatted)
		512: return _justice_description(stats, bb_formatted)
		513: return _hanged_man_description(stats, bb_formatted)
		514: return _death_description(stats, bb_formatted)
		515: return _temperance_description(stats, bb_formatted)
		516: return _devil_description(stats, bb_formatted)
		517: return _tower_description(stats, bb_formatted)
		518: return _star_description(stats, bb_formatted)
		519: return _moon_description(stats, bb_formatted)
		520: return _sun_description(stats, bb_formatted)
		521: return _judgement_description(stats, bb_formatted)
		522: return _world_description()
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
	return ("Embrace the leap into the unknown. Immediately shuffle your deck, starting fresh. You " +
			format_positive_negative("keep", "lose", bb_formatted) +
			" all of your current bonuses in this new beginning.")

static func _magician_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.magician)
	return ("Channel your will to reshape reality. Pick a suit and manifest change: " + count + " random cards from this suit are " +
			format_positive_negative("conjured into", "banished from", bb_formatted) +
			" your deck until your next shuffle.")

static func _high_priestess_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.high_priestess)
	return ("Channel mystical transformation through ghostly power. For the next " + count + " cards drawn, witness spectral magic as your card " +
			format_positive_negative("transforms into your chosen replacement", "is forcibly transformed by unseen forces", bb_formatted) + 
			".")

static func _empress_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.empress)
	return ("Embrace the nurturing power of maternal wisdom. Gathers the essence of the last " + count + " card values drawn, then " +
			format_positive_negative("blesses", "curses", bb_formatted) +
			" you with their combined power. This fertile accumulation lasts until your next shuffle.")

static func _emperor_description(stats: MajorStats, bb_formatted: bool) -> String:
	var value = str(stats.emperor)
	return ("Command with absolute imperial authority. Royal decree " +
			format_positive_negative("elevates", "diminishes", bb_formatted) + 
			" the value of every card you draw by " + value + ". This sovereign rule lasts until your next shuffle.")

static func _hierophant_description(stats: MajorStats, bb_formatted: bool) -> String:
	var uses = str(stats.hierophant)
	return ("Bestow divine guidance through sacred doctrine. The next " + uses + " cards receive spiritual intervention: " +
			format_positive_negative("blessed cards double their value", "cursed cards lose half their power", bb_formatted) +
			". Each blessing or curse consumes one use of this holy power.")

static func _lovers_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.lovers)
	return ("Experience the profound power of connection and choice. The sacred bonds of love " +
			format_positive_negative("form " + count + " new connections by duplicating random cards from your deck", "break " + count + " existing connections by removing duplicate cards", bb_formatted) +
			", weaving the threads of fate to reflect unity or separation. These bonds reshape your deck's very essence until your next shuffle.")

static func _chariot_description(bb_formatted: bool) -> String:
	return ("Harness the unstoppable momentum of determination and willpower. The Chariot begins tracking your card values, building an ascending chain where each card's final value must equal or exceed the previous. " +
			"When the chain inevitably breaks, " +
			format_positive_negative("victory grants you", "defeat costs you", bb_formatted) +
			" Clairvoyance equal to the sum of all chained values. The Chariot then enters dormancy until drawn again, awaiting the next journey.")

static func _strength_description(stats: MajorStats, bb_formatted: bool) -> String:
	var bonus = str(stats.strength)
	return ("Build endurance through persistence. Each card drawn " +
			format_positive_negative("adds +" + bonus, "adds -" + bonus, bb_formatted) +
			" to a growing bonus that affects all future cards until your next shuffle. " +
			"Rewards sustained play with escalating power.")

static func _hermit_description(bb_formatted: bool) -> String:
	return ("Walk the Enlightened Path, gaining wisdom through experience. " +
			format_positive_negative("Discovery: +2 bonus for each NEW card type encountered", 
			"Repetition: +2 bonus for each REPEATED card type drawn", bb_formatted) +
			". Accumulated wisdom affects all future cards until your next shuffle.")

static func _wheel_of_fortune_description(stats: MajorStats, bb_formatted: bool) -> String:
	var charges = str(stats.wheel_charges)
	var mult = str(stats.wheel_multiplier)
	return ("Spin the cosmic wheel and choose your destiny. Pick a suit, then fate decides: if the next card matches, the wheel " +
			format_positive_negative("blesses", "curses", bb_formatted) +
			" your next " + charges + " cards by " + 
			format_positive_negative("multiplying by " + mult, "dividing by " + mult, bb_formatted) + 
			". If it fails, the wheel's fortune reverses.")

static func _justice_description(stats: MajorStats, bb_formatted: bool) -> String:
	var threshold = str(stats.justice)
	return ("Invoke the cosmic scales of karmic balance. Justice adds a second copy of itself to your deck and begins tracking the magnitude of your fortune. " +
			"When the second Justice appears, " +
			format_positive_negative("fair settlement pays karmic debts and credits based on your recent performance above " + threshold, 
			"harsh judgment demands extra payment for extraordinary fortune while denying compensation for poor luck below " + threshold, bb_formatted) + 
			". The universe always balances its books.")

static func _hanged_man_description(stats: MajorStats, bb_formatted: bool) -> String:
	var inversion_power = str(stats.hanged_man)
	return ("Embrace the wisdom of inverted perspective. The Hanged Man sees worth where others see weakness, transforming the natural hierarchy of card values with power level " + inversion_power + ". " +
			format_positive_negative("surrendering control grants enlightened inversion where Kings become Aces and wisdom flows predictably", 
			"resisting the lesson creates chaotic transformation where values become unpredictable and usually diminished", bb_formatted) + 
			". True insight comes from accepting the upside-down view of the world.")

static func _death_description(stats: MajorStats, bb_formatted: bool) -> String:
	var multiplier = str(stats.death)
	return ("Embrace the profound transformation of endings and new beginnings. Death sweeps through your spiritual realm, " +
			format_positive_negative("purging all dark influences and curses", "clearing away all blessings and positive energies", bb_formatted) +
			" across every aspect of your being. From this sacred cleansing, receive " + multiplier + 
			"x Clairvoyance - a rebirth gift measured by the magnitude of what was released and the wisdom of your recent journey.")

static func _temperance_description(stats: MajorStats, bb_formatted: bool) -> String:
	var value = str(stats.temperance)
	return ("Channel the divine art of alchemical balance, where extremes dissolve into perfect harmony. Through sacred moderation, Temperance " +
			format_positive_negative("lifts the weak to strength, ensuring no card falls below " + value, "tempers the overwhelming, capping all excess above " + value, bb_formatted) +
			". This celestial equilibrium guides every card until your next spiritual renewal.")

static func _devil_description(stats: MajorStats, bb_formatted: bool) -> String:
	var count = str(stats.devil)
	return ("Enter the seductive dance of temptation and liberation. The Devil weaves itself deeper into your deck's very fabric, creating chains of desire. Gain " + count + " dark charges to " +
			format_positive_negative("choose your moments of willful rebellion against fate", "be compelled by addiction to automatically reject " + count + " offerings", bb_formatted) +
			". Yet within these chains lies freedom - use the Devil's own power to banish future Devils and break the cycle of bondage.")

static func _tower_description(stats: MajorStats, bb_formatted: bool) -> String:
	var base_power = str(stats.tower)
	return ("Witness the catastrophic beauty of sudden upheaval as divine lightning strikes the foundations of certainty. Each Tower's appearance deepens the chaos, " +
			format_positive_negative("amplifying fortune through cascading revelation", "crushing hope through escalating devastation", bb_formatted) +
			" with base power " + base_power + " that grows ever more intense. The more Towers pierce the veil, the more reality itself trembles and warps, until only the sacred act of shuffling can rebuild from the sublime wreckage.")

static func _star_description(stats: MajorStats, bb_formatted: bool) -> String:
	var base_power = str(stats.star)
	return ("Channel celestial hope that " +
			format_positive_negative("accumulates +" + base_power + " star power with each drawing", "corrupts into a fallen star, reducing power by -" + base_power + " with each drawing", bb_formatted) +
			". When combined with Moons and Suns, transforms into exponential divine guidance through the formula: (star power)^(1 + moons + suns).")

static func _moon_description(stats: MajorStats, bb_formatted: bool) -> String:
	var stars_added = str(stats.moon)
	var exponent_power = str(stats.moon_exponent)
	return ("Witness the mystical phases that " +
			format_positive_negative("amplify celestial power exponentially (+" + exponent_power + " per Moon to exponent) and manifest " + stars_added + " new Stars", "wane into darkness, reducing exponential power (-" + exponent_power + " per Moon to exponent) while making Stars illuminate negative cards", bb_formatted) +
			". The lunar cycle governs how reality bends to stellar will.")

static func _sun_description(stats: MajorStats, bb_formatted: bool) -> String:
	var star_count = str(stats.sun_star)
	var moon_count = str(stats.sun_moon)
	var exponent_power = str(stats.sun_exponent)
	return ("Behold the ultimate celestial force that " +
			format_positive_negative("manifests " + star_count + " Stars and " + moon_count + " Moons while adding +" + exponent_power + " per Sun to the exponential formula, creating cascade effects of cosmic proportions", 
			"eclipses into darkness, banishing ALL celestial bodies and resetting amplification to zero", bb_formatted) +
			". The Sun's radiance determines whether your celestial engine ascends to godhood or collapses into void.")

static func _judgement_description(stats: MajorStats, bb_formatted: bool) -> String:
	var power = str(stats.judgement)
	return ("Behold the ultimate conductor of divine will that orchestrates all major arcana into cosmic symphony. Judgement " +
			format_positive_negative("exponentially amplifies every card using the transcendent formula: unique_majors^(" + power + " x judgements_drawn)", 
			"exponentially diminishes every card using the inverse formula: unique_majors^(-" + power + " x judgements_drawn)", bb_formatted) +
			". The more diverse your major arcana collection, the more astronomical the transformation becomes. This is the crescendo that transforms mortal mathematics into divine revelation.")

static func _world_description() -> String:
	return "The Tower completes the full Arcana, resetting your Tarot Progress and giving you a Deck to spend."