extends Node
class_name CardDescriptions

static func get_description(card:DataStructures.Card, _bb_formatted = false) -> Dictionary:
	var output: Dictionary = {}
	var card_output: String = ""
	var good_color: String = ("[color=%s]"%[ID.SuitColor["GOOD"].to_html(false)] if _bb_formatted else "")
	var bad_color: String = ("[color=%s]"%[ID.SuitColor["BAD"].to_html(false)] if _bb_formatted else "")
	var end_color_tag: String = ("[/color]"if _bb_formatted else "")
	print(good_color)
	if card.card_id_num < 500 && card.card_id_num % 100 < 11:
		card_output += "Basic: This card triggers it's suit effect and value."
	else:
		match card.card_id_num:
			111:
				card_output += ("Multiply your maximum cup size by "+
							good_color+"%s"%[GameManager.game_state.stats.cup_stats.page_modifier]+end_color_tag+
							" / "+
							bad_color+"%s"%[GameManager.game_state.stats.cup_stats.page_modifier]+end_color_tag+
							"."
							)
			112:
				card_output += (good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"remove"+end_color_tag+
							" %s random Cup card(s) to / from the deck."%[GameManager.game_state.stats.cup_stats.knight_modifier]
							)
			113:
				card_output += (good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"remove"+end_color_tag+
							" %s Cup bank(s). (You will always have 1 minimum)"%[GameManager.game_state.stats.cup_stats.queen_modifier]
							)
			114:
				card_output += ("Immediately "+
							good_color+"Fill"+end_color_tag+
							" / "+
							bad_color+"Empty"+end_color_tag+
							" all Cup banks."
							)
			211:
				card_output +=("Next drawn Wand card triggers "+
							good_color+"%s"%[GameManager.game_state.stats.wand_stats.page_modifier]+end_color_tag+
							" / "+
							bad_color+"0"+end_color_tag+
							" times."
							)
			212:
				card_output +=("Next drawn card (any suit) is "+
							good_color+"Multiplied"+end_color_tag+
							" / "+
							bad_color+"Divided"+end_color_tag+
							" by your Wand strength."
							)
			213:
				card_output +=("All Wand values are "+
							good_color+"Increased"+end_color_tag+
							" / "+
							bad_color+"Decreased"+end_color_tag+
							" by %s until your next reshuffle."%[GameManager.game_state.stats.wand_stats.queen_modifier]
							)
			214:
				card_output += ("Your Wand strength is raised to the power of "+
							good_color+"%s"%[GameManager.game_state.stats.wand_stats.king_modifier]+end_color_tag+
							" / "+
							bad_color+"1/%s"%[GameManager.game_state.stats.wand_stats.king_modifier]+end_color_tag+
							"."
							)
			311:
				card_output += ("Your Protection is multiplied by "+
							good_color+"%s"%[GameManager.game_state.stats.pentacle_stats.page_modifier]+end_color_tag+
							" / "+
							bad_color+"1/%s"%[GameManager.game_state.stats.pentacle_stats.page_modifier]+end_color_tag+
							"."
							)
			312:
				card_output +=("Your Protection is "+
							good_color+"given %s extra uses"%[GameManager.game_state.stats.pentacle_stats.knight_uses]+end_color_tag+
							" / "+
							bad_color+"cleared"+end_color_tag+
							"."
							)
			313:
				card_output += ("Flips your next %s "%[GameManager.game_state.stats.pentacle_stats.queen_uses]+
							good_color+"inverted"+end_color_tag+
							" / "+
							bad_color+"upright"+end_color_tag+
							"cards to the opposite orientation."
							)
			314:
				card_output += (good_color+"Gives you +%s Protection and +%s charges"%[GameManager.game_state.stats.pentacle_stats.king_value, GameManager.game_state.stats.pentacle_stats.king_uses]+end_color_tag+
							" / "+
							bad_color+"Blocks Protection until next shuffle"+end_color_tag
							)
			411:
				card_output +=("Next sword card is raised to the power of your Combo, and then "+
							good_color+"Added"+end_color_tag+
							" / "+
							bad_color+"Subtracted"+end_color_tag+
							" from your total."
							)
			412:
				card_output +=(good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"Remove"+end_color_tag+
								" 1 random unlocked card below %s (%s including majors) for each combo point you have."%[GameManager.game_state.stats.sword_stats.knight_modifier, "" if GameManager.game_state.stats.sword_stats.knight_super else "not"]
							)
			413:
				card_output += ("Each Combo point is worth"+
							good_color+"+%s"%[GameManager.game_state.stats.sword_stats.queen_modifier]+end_color_tag+
							" / "+
							bad_color+"-%s"%[GameManager.game_state.stats.sword_stats.queen_modifier]+end_color_tag+
							"."
							)
			414:
				card_output +=("Your Combo is "+
							good_color+"protected"+end_color_tag+
							" / "+
							bad_color+"broken"+end_color_tag+
							" the next %s times it would otherwise be "%[GameManager.game_state.stats.sword_stats.king_modifier]+
							good_color+"decreased"+end_color_tag+
							" / "+
							bad_color+"increased"+end_color_tag+
							"."
							)
			501:
				card_output += ("Immediately shuffle your deck. You "+
							good_color+"keep"+end_color_tag+
							" / "+
							bad_color+"lose"+end_color_tag+
							" all of your current bonus'."
							)
			502:
				card_output +=("Pick a suit. %s random cards from this suit are "%[GameManager.game_state.stats.major_stats.magician]+
							good_color+"added"+end_color_tag+
							" / "+
							bad_color+"removed"+end_color_tag+
							" until your next shuffle."
							)			
			503:
				card_output += ("Reveals the next %s cards in your deck without drawing them."%[GameManager.game_state.stats.major_stats.high_priestess]+
							" / "+
							"Hides the next %s cards from view until drawn."%[GameManager.game_state.stats.major_stats.high_priestess]
							)
			504:
				card_output +=("Remembers the last %s card(s) drawn and then "%[GameManager.game_state.stats.major_stats.empress]+
							good_color+"adds"+end_color_tag+
							" / "+
							bad_color+"removes"+end_color_tag+
							" the value from your next card's total. Lasts until your next shuffle."
							)
			505:
				card_output +=(good_color+"Increase "+end_color_tag+
							" / "+
							bad_color+"decrease"+end_color_tag+
							" the base value of your cards by %s. Lasts until your next shuffle."%[GameManager.game_state.stats.major_stats.emperor]
							)
			506:
				card_output += ("All cards of the same suit as the next drawn card get a "+
							good_color+"bonus multiplier"+end_color_tag+
							" / "+
							bad_color+"penalty"+end_color_tag+
							" until your next shuffle."
							)
			507:
				card_output += (good_color+"Copy %s cards "%[GameManager.game_state.stats.major_stats.lovers]+end_color_tag+
							" / "+
							bad_color+"remove %s duplicate cards"%[GameManager.game_state.stats.major_stats.lovers]+end_color_tag+
							" in/from your deck until your next shuffle."
							)
			508:
				card_output += ("If your current card is of higher base value than your previous card, multiply your total by that value."+
							" When you draw a card that's lower, "+
							good_color+"increase"+end_color_tag+
							" / "+
							bad_color+"decrease"+end_color_tag+
							" your Clairvoyance by the total."
							)
			509:
				card_output += ("Convert negative card values to "+
							good_color+"positive"+end_color_tag+
							" / "+
							bad_color+"positive to negative"+end_color_tag+
							" for the next %s cards."%[GameManager.game_state.stats.major_stats.strength]
							)
			510:
				card_output += ("If your remaining deck contains no duplicates, "+
							good_color+"double your clairvoyance, "+end_color_tag+
							" otherwise "+
							bad_color+"half it."+end_color_tag
							)
			511:
				card_output += ("Pick a suit. If the next card drawn matches that suit, "+
							good_color+"multiply"+end_color_tag+
							" / "+
							bad_color+"divide"+end_color_tag+
							" the next %s cards by %s."%[GameManager.game_state.stats.major_stats.wheel_charges, GameManager.game_state.stats.major_stats.wheel_mult]
							)
			512:
				card_output += ("Balance your deck by ensuring "+
							good_color+"equal numbers of each suit"+end_color_tag+
							" / "+
							bad_color+"removing cards from the most common suit"+end_color_tag+
							"."
							)
			513:
				card_output += "Currently Unavailable"
			514:
				card_output += ("Transform all cards in your deck to a "+
							good_color+"random suit"+end_color_tag+
							" / "+
							bad_color+"remove all cards of a specific suit"+end_color_tag+
							"."
							)
			515:
				card_output += ("All cards will score a "+
							good_color+"minimum"+end_color_tag+
							" / "+
							bad_color+"maximum"+end_color_tag+
							" of %s until your next shuffle."%[GameManager.game_state.stats.major_stats.temperance]
							)
			516:
				card_output += ("Adds another Devil to your deck. You "+
							good_color + "  may " + end_color_tag +
							" / "+
							bad_color + " must " + end_color_tag +
								" skip %s cards."%[GameManager.game_state.stats.major_stats.devil])
			517:
				card_output += ("Adds another tower to your deck. "+
							good_color+"Double"+end_color_tag+
							" / "+
							bad_color+"half"+end_color_tag+
							" your cards value. Swap this effect when the other tower is drawn. Resets on your next shuffle."
							)
			518:
				card_output += ("Adds %s to the base value of all positive cards. Can be affected by The Moon."%[GameManager.game_state.stats.major_stats.star]+
							" Lasts until your next shuffle")
			519:
				card_output += (good_color+"Multiply star value by %s"%[GameManager.game_state.stats.major_stats.moon]+end_color_tag+
							" / "+
							bad_color+"Stars now work on negative cards"+end_color_tag+
							" until your next shuffle"
							)
			520:
				card_output += (good_color+"Add %s of The Star and %s of The Moon to your deck"%[GameManager.game_state.stats.major_stats.sun_star, GameManager.game_state.stats.major_stats.sun_moon]+end_color_tag+
							" / "+
							bad_color+"remove all copies of The Star and The Moon from your deck"+end_color_tag+
							" until your next shuffle."
							)
			521:
				card_output += ("Judgement "+good_color+"multiplies"+end_color_tag+" / "+
							bad_color+"divides"+end_color_tag+
							" the value of every card by %s until your next shuffle."%[GameManager.game_state.stats.major_stats.judgement])
			522:
				card_output += "The Tower completes the full Arcana, resetting your Tarot Progress and giving you a Deck to spend."
					
	output["card"] = card_output

	var suit_output: String = ""
	match card.card_suit:
		DataStructures.SuitType.CUPS:
			suit_output += (("[color=%s]"%[ID.SuitColor["CUPS"].to_html()] if _bb_formatted else "")+
						"Cups: "+end_color_tag+
						"Whenever a Cup card is drawn, "+
						good_color+"Add"+end_color_tag+
						" / "+
						bad_color+"Remove"+end_color_tag+
						" some Clairvoyance to your cups, then gain clairvoyance equal to the total of your cups."
						)
		DataStructures.SuitType.WANDS:
			suit_output += (("[color=%s]"%[ID.SuitColor["WANDS"].to_html()] if _bb_formatted else "")+
						"Wands: "+end_color_tag+
						"Whenever a Wand card is drawn, "+
						good_color+"Increase"+end_color_tag+
						" / "+
						bad_color+"Decrease"+end_color_tag+
						" your wand multiplier, then gain clairvoyance equal to the card's multiplied value."
						)
		DataStructures.SuitType.PENTACLES:
			suit_output += (("[color=%s]"%[ID.SuitColor["PENTACLES"].to_html()] if _bb_formatted else "")+
						"Pentacles: "+end_color_tag+
						"Whenever a Pentacle card is drawn, "+
						good_color+"Increase"+end_color_tag+
						" / "+
						bad_color+"Decrease"+end_color_tag+
						" your Pentacle protection value, when you next draw an Inverted card, your losses will be reduced by this protection."
						)
		DataStructures.SuitType.SWORDS:
			suit_output += (("[color=%s]"%[ID.SuitColor["SWORDS"].to_html()] if _bb_formatted else "")+
						"Swords: "+end_color_tag+
						"Whenever a Swords card is drawn, if it matches the orientation ("+
						good_color+"Upright"+end_color_tag+
						" / "+
						bad_color+"Inverted"+end_color_tag+
						") of your last swords card, increase your combo. Sword values get multiplied by this combo."
						)
		_:
			suit_output += (("[color=%s]"%[ID.SuitColor["MAJOR"].to_html()] if _bb_formatted else "")+
						"Major Arcana: "+
						end_color_tag+
						"Each card has it's own unique effect."
						)
	output["suit"] = suit_output
	return output
