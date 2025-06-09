extends Node
class_name CardDescriptions


func get_description(card:Card, _bb_formatted = false) -> String:
	var output: String = ""
	var good_color: String = ("[color=#%s]"%[ID.SuitColor["GOOD"].to_html(false)] if _bb_formatted else "")
	var bad_color: String = ("[color=#%s]"%[ID.SuitColor["BAD"].to_html(false)] if _bb_formatted else "")
	var end_color_tag: String = ("[/color]"if _bb_formatted else "")
	print(good_color)
	if card.card_id_num < 500 && card.card_id_num % 100 < 11:
		output += "Basic: This card triggers it's suit effect and value."
	else:
		match card.card_id_num:
			111:
				output += ("Multiply your maximum cup size by "+
							good_color+"%s"%[Stats.cup_page_positive]+end_color_tag+
							" / "+
							bad_color+"%s"%[Stats.cup_page_negative]+end_color_tag+
							"."
							)
			112:
				output += (good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"remove"+end_color_tag+
							" %s random Cup card(s) to / from the deck."%[Stats.cup_knight_mod]
							)
			113:
				output += (good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"remove"+end_color_tag+
							" %s Cup bank(s). (You will always have 1 minimum)"%[Stats.cup_queen_mod]
							)
			114:
				output += ("Immediately "+
							good_color+"Fill"+end_color_tag+
							" / "+
							bad_color+"Empty"+end_color_tag+
							" all Cup banks."
							)
			211:
				output +=("Next drawn Wand card triggers "+
							good_color+"%s"%[Stats.wand_page_mod]+end_color_tag+
							" / "+
							bad_color+"0"+end_color_tag+
							" times."
							)
			212:
				output +=("Next drawn card (any suit) is "+
							good_color+"Multiplied"+end_color_tag+
							" / "+
							bad_color+"Divided"+end_color_tag+
							" by your Wand strength."
							)
			213:
				output +=("All Wand values are "+
							good_color+"Increased"+end_color_tag+
							" / "+
							bad_color+"Decreased"+end_color_tag+
							" by %s until your next reshuffle."%[Stats.wand_queen_mod]
							)
			214:
				output += ("Your Wand strength is raised to the power of "+
							good_color+"%s"%[Stats.wand_king_mod]+end_color_tag+
							" / "+
							bad_color+"1/%s"%[Stats.wand_king_mod]+end_color_tag+
							"."
							)
			311:
				output += ("Your Protection is multiplied by "+
							good_color+"%s"%[Stats.pent_page_positive]+end_color_tag+
							" / "+
							bad_color+"1/%s"%[Stats.pent_page_negative]+end_color_tag+
							"."
							)
			312:
				output +=("Your Protection is "+
							good_color+"given %s extra uses"%[Stats.pent_knight_uses]+end_color_tag+
							" / "+
							bad_color+"cleared"+end_color_tag+
							"."
							)
			313:
				output += ("Flips your next %s "%[Stats.pent_queen_uses]+
							good_color+"inverted"+end_color_tag+
							" / "+
							bad_color+"upright"+end_color_tag+
							"cards to the opposite orientation."
							)
			314:
				output += (good_color+"Gives you +%s Protection and +%s charges"%[Stats.pent_king_value, Stats.pent_king_uses]+end_color_tag+
							" / "+
							bad_color+"Blocks Protection until next shuffle"+end_color_tag
							)
			411:
				output +=("Next sword card is raised to the power of your Combo, and then "+
							good_color+"Added"+end_color_tag+
							" / "+
							bad_color+"Subtracted"+end_color_tag+
							" from your total."
							)
			412:
				output +=(good_color+"Add"+end_color_tag+
							" / "+
							bad_color+"Remove"+end_color_tag+
							" %s random unlocked card for each combo point you have."%[Stats.sword_knight_mod]
							)
			413:
				output += ("Each Combo point is worth"+
							good_color+"+%s"%[Stats.sword_queen_mod]+end_color_tag+
							" / "+
							bad_color+"-%s"%[Stats.sword_queen_mod]+end_color_tag+
							"."
							)
			414:
				output +=("Your Combo is "+
							good_color+"protected"+end_color_tag+
							" / "+
							bad_color+"broken"+end_color_tag+
							" the next %s times it would otherwise be "%[Stats.sword_king_mod]+
							good_color+"decreased"+end_color_tag+
							" / "+
							bad_color+"increased"+end_color_tag+
							"."
							)
			501:
				output += ("Immediately shuffle your deck. You "+
							good_color+"keep"+end_color_tag+
							" / "+
							bad_color+"lose"+end_color_tag+
							" all of your current bonus'."
							)
			502:
				output +=("Pick a suit. %s random cards from this suit are "%[Stats.major_magician]+
							good_color+"added"+end_color_tag+
							" / "+
							bad_color+"removed"+end_color_tag+
							" until your next shuffle."
							)			
			503:
				output +=""
			504:
				output +=""
	
	var suit_output: String = "\n\n"
	match card.card_suit:
		ID.Suits.CUPS:
			suit_output += (("[color=#%s]"%[ID.SuitColor["CUPS"].to_html()] if _bb_formatted else "")+
						"Cups: "+end_color_tag+
						"Whenever a Cup card is drawn, "+
						good_color+"Add"+end_color_tag+
						" / "+
						bad_color+"Remove"+end_color_tag+
						" some Clairvoyance to your cups, then gain clairvoyance equal to the total of your cups."
						)
		ID.Suits.WANDS:
			suit_output += (("[color=#%s]"%[ID.SuitColor["WANDS"].to_html()] if _bb_formatted else "")+
						"Wands: "+end_color_tag+
						"Whenever a Wand card is drawn, "+
						good_color+"Increase"+end_color_tag+
						" / "+
						bad_color+"Decrease"+end_color_tag+
						" your wand multiplier, then gain clairvoyance equal to the card's multiplied value."
						)
		ID.Suits.PENTACLES:
			suit_output += (("[color=#%s]"%[ID.SuitColor["PENTACLES"].to_html()] if _bb_formatted else "")+
						"Pentacles: "+end_color_tag+
						"Whenever a Pentacle card is drawn, "+
						good_color+"Increase"+end_color_tag+
						" / "+
						bad_color+"Decrease"+end_color_tag+
						" your Pentacle protection value, when you next draw an Inverted card, your losses will be reduced by this protection."
						)
		ID.Suits.SWORDS:
			suit_output += (("[color=#%s]"%[ID.SuitColor["SWORDS"].to_html()] if _bb_formatted else "")+
						"Swords: "+end_color_tag+
						"Whenever a Swords card is drawn, if it matches the orientation ("+
						good_color+"Upright"+end_color_tag+
						" / "+
						bad_color+"Inverted"+end_color_tag+
						") of your last swords card, increase your combo. Sword values get multiplied by this combo."
						)
		_:
			suit_output += ("All"+
						("[color=#%s]"%[ID.SuitColor["MAJOR"].to_html()] if _bb_formatted else "")+
						"Major Arcana"+
						end_color_tag+
						"have unique effects."
						)
	output += suit_output
	return output
