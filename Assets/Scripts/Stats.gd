extends Node

@export var current_currency: int:
	get:
		return current_currency
	set(value):
		current_currency = value


"""
General:
	gen_inversion_chance_mod
	gen_max_deck_size
	gen_min_deck_size
"""
#Reminder that Inversion Chance is a positive percentage that modifies the chance of being upright
@export var gen_inversion_chance_mod: float = 0 :
	get:
		return gen_inversion_chance_mod
	set(value):
		gen_inversion_chance_mod = value

@export var gen_max_deck_size: int = 56 :
	get:
		return gen_max_deck_size
	set(value):
		gen_max_deck_size = value

@export var gen_min_deck_size: int = 56 :
	get:
		return gen_min_deck_size
	set(value):
		gen_min_deck_size = value

"""
Cups:
	cup_max_quant
	cup_max_size
	cup_basic_value
	cup_basic_quant
"""

@export var cup_max_quant: int = 1:
	get:
		return cup_max_quant
	set(value):
		cup_max_quant = value

@export var cup_max_size: int = 1:
	get:
		return cup_max_size
	set(value):
		cup_max_size = value

@export var cup_basic_value: int = 0:
	get:
		return cup_basic_value
	set(value):
		cup_basic_value = value

@export var cup_basic_quant: int = 1:
	get:
		return cup_basic_quant
	set(value):
		cup_basic_quant = value

"""
Wands:
	wand_basic_value
	wand_basic_quant
"""

@export var wand_basic_value: int = 0:
	get:
		return wand_basic_value
	set(value):
		wand_basic_value = value

@export var wand_basic_quant: int = 1:
	get:
		return wand_basic_quant
	set(value):
		wand_basic_quant = value

"""
Pentacles:
	pent_basic_value
	pent_basic_quant
"""

@export var pent_basic_value: int = 0:
	get:
		return pent_basic_value
	set(value):
		pent_basic_value = value

@export var pent_basic_quant: int = 1:
	get:
		return pent_basic_quant
	set(value):
		pent_basic_quant = value

"""
Swords:
	sword_basic_value
	sword_basic_quant
"""

@export var sword_basic_value: int = 0:
	get:
		return sword_basic_value
	set(value):
		sword_basic_value = value

@export var sword_basic_quant: int = 1:
	get:
		return sword_basic_quant
	set(value):
		sword_basic_quant = value

"""
Major:
	major_quant
"""
@export var major_quant: int = 1:
	get:
		return major_quant
	set(value):
		major_quant = value

"""
Quick-Get Section
"""
func Card_max_quant(card: Card):
	if card.card_suit == Card.Suits.cups:
		if card.card_id_num <= 110:
			return Stats.cup_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == Card.Suits.wands:
		if card.card_id_num <= 210:
			return Stats.wand_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == Card.Suits.pentacles:
		if card.card_id_num <= 310:
			return Stats.pent_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == Card.Suits.swords:
		if card.card_id_num <= 410:
			return Stats.sword_basic_quant
		#TEMPORARY UNTIL PICTURES ARE INCLUDED
		return 1
	if card.card_suit == Card.Suits.major:
		return Stats.major_quant
