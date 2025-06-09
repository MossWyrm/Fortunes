extends Node

var current_currency: int
var pause_drawing: bool = false:
	set(value):
		Events.emit_pause_drawing(value)
		pause_drawing = value
	get:
		return pause_drawing

"""
General:
"""
#Reminder that Inversion Chance is a positive percentage that modifies the chance of being upright
var gen_inversion_chance_mod: float = 0
var gen_max_deck_size: int = 56
var gen_min_deck_size: int = 56

"""
Cups:
"""
var cup_max_quant: int = 1
var cup_max_size: int = 100
var cup_max_size_modifier: int = 0
var cup_basic_value: int = 0
var cup_basic_quant: int = 1
var cup_page_positive: float = 1.1
var cup_page_negative: float = 0.9
var cup_knight_mod: int = 1
var cup_queen_mod: int = 1

"""
Wands:
"""
var wand_basic_value: int = 0
var wand_basic_quant: int = 1 
var wand_page_mod: int = 1
var wand_knight_mod: int = 1
var wand_queen_mod: int = 1
var wand_king_mod: int = 2

"""
Pentacles:
"""
var pent_basic_value: int = 0
var pent_basic_quant: int = 1
var pent_page_positive: float = 1.1
var pent_page_negative: float = 0.9
var pent_knight_uses: int = 1
var pent_queen_uses: int = 1
var pent_king_uses: int = 3
var pent_king_value: int = 100

"""
Swords:
"""
var sword_basic_value: int = 0
var sword_basic_quant: int = 1
var sword_knight_mod: int = 10
var sword_knight_super: bool = false
var sword_queen_mod: int = 1
var sword_king_mod: int = 3

"""
Major:
"""
var major_quant: int = 1
var major_magician: int = 5

"""
Quick-Get Section
"""
func card_max_quant(card: Card):
	if card.card_suit == ID.Suits.CUPS:
		if card.card_id_num <= 110:
			return Stats.cup_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == ID.Suits.WANDS:
		if card.card_id_num <= 210:
			return Stats.wand_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == ID.Suits.PENTACLES:
		if card.card_id_num <= 310:
			return Stats.pent_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == ID.Suits.SWORDS:
		if card.card_id_num <= 410:
			return Stats.sword_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == ID.Suits.MAJOR:
		return Stats.major_quant
