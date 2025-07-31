extends Node

var clairvoyance: int
var packs: int = 0
var pause_drawing: bool = false:
	set(value):
		Events.emit_pause_drawing(value)
		pause_drawing = value
	get:
		return pause_drawing
var tutorial_complete: bool = false

"""
General:
"""
#Reminder that Inversion Chance is a positive percentage that modifies the chance of being upright
var gen_inversion_chance_mod: float = 0 #IMPLEMENTED
var gen_max_deck_size: int = 56 #IMPLEMENTED
var gen_min_deck_size: int = 56 #IMPLEMENTED

"""
Cups:
"""
var cup_basic_value: int = 0 #IMPLEMENTED
var cup_basic_quant: int = 1  #IMPLEMENTED
var cup_face_quant: int = 1 #IMPLEMENTED
var cup_vessel_size: int = 100 #IMPLEMENTED
var cup_vessel_quant: int = 1 #IMPLEMENTED
var cup_page_mod: float = 0.2 #IMPLEMENTED
var cup_knight_mod: int = 1 #IMPLEMENTED
var cup_queen_mod: int = 1 #IMPLEMENTED

"""
Wands:
"""
var wand_basic_value: int = 0 #IMPLEMENTED
var wand_basic_quant: int = 1  #IMPLEMENTED
var wand_face_quant: int = 1 #IMPLEMENTED
var wand_page_mod: int = 1 #IMPLEMENTED
var wand_knight_mod: int = 1 #IMPLEMENTED
var wand_queen_mod: int = 1 #IMPLEMENTED
var wand_king_mod: int = 2 #IMPLEMENTED

"""
Pentacles:
"""
var pent_basic_value: int = 0 #IMPLEMENTED
var pent_basic_quant: int = 1 #IMPLEMENTED
var pent_face_quant: int = 1 #IMPLEMENTED
var pent_page_mod: float = 0.1 #IMPLEMENTED
var pent_knight_uses: int = 1 #IMPLEMENTED
var pent_queen_uses: int = 1 #IMPLEMENTED
var pent_king_uses: int = 3 #IMPLEMENTED
var pent_king_value: int = 100 #IMPLEMENTED

"""
Swords:
"""
var sword_basic_value: int = 0 #IMPLEMENTED
var sword_basic_quant: int = 1 #IMPLEMENTED
var sword_face_quant: int = 1 #IMPLEMENTED
var sword_knight_mod: int = 5 #IMPLEMENTED
var sword_knight_super: bool = false #IMPLEMENTED
var sword_queen_mod: int = 1 #IMPLEMENTED
var sword_king_mod: int = 3 #IMPLEMENTED

"""
Major:
"""
var major_quant: int = 1 #IMPLEMENTED
var major_magician: int = 5 #IMPLEMENTED
var major_empress: int = 1 #IMPLEMENTED
var major_emperor: int = 1 #IMPLEMENTED
var major_lovers: int = 4 #IMPLEMENTED
var major_wheel_mult: int = 2 #IMPLEMENTED
var major_wheel_charges: int = 5 #IMPLEMENTED
var major_hanged_man: int = 2 #IMPLEMENTED
var major_temperance: int = 100 #IMPLEMENTED
var major_devil: int = 3 
var major_star: int = 5 #IMPLEMENTED
var major_moon: int = 2 #IMPLEMENTED
var major_sun_star: int = 10 #IMPLEMENTED
var major_sun_moon: int = 3 #IMPLEMENTED
var major_judgement: int = 10 #IMPLEMENTED

"""
Packs:
"""
var pack_auto_draw: bool = false
var pack_auto_draw_speed: float = 5.0
var pack_card_value: int = 1

func _ready() -> void:
	Events.reset.connect(reset_game)
	
func card_max_quant(card: Card) -> int:
	if card.card_suit == ID.Suits.CUPS:
		if card.card_id_num <= 110:
			return cup_basic_quant
		return cup_face_quant
	if card.card_suit == ID.Suits.WANDS:
		if card.card_id_num <= 210:
			return wand_basic_quant
		return wand_face_quant
	if card.card_suit == ID.Suits.PENTACLES:
		if card.card_id_num <= 310:
			return pent_basic_quant
		return pent_face_quant
	if card.card_suit == ID.Suits.SWORDS:
		if card.card_id_num <= 410:
			return sword_basic_quant
		return sword_face_quant
	if card.card_suit == ID.Suits.MAJOR:
		return major_quant
	else: 
		return 0

func reset_deck() -> void:
	gen_inversion_chance_mod = 0
	gen_max_deck_size = 56
	gen_min_deck_size = 56
	
	"""
	Cups:
	"""
	cup_basic_value = 0
	cup_basic_quant = 1
	cup_face_quant = 1
	cup_vessel_quant = 1
	cup_vessel_size = 100
	cup_page_mod = 0.2
	cup_knight_mod = 1
	cup_queen_mod = 1
	
	"""
	Wands:
	"""
	wand_basic_value = 0
	wand_basic_quant = 1
	wand_face_quant = 1
	wand_page_mod = 1
	wand_knight_mod = 1
	wand_queen_mod = 1
	wand_king_mod = 2
	
	"""
	Pentacles:
	"""
	pent_basic_value = 0
	pent_basic_quant = 1
	pent_face_quant = 1
	pent_page_mod = 0.1
	pent_knight_uses = 1
	pent_queen_uses = 1
	pent_king_uses = 3
	pent_king_value= 100
	
	"""
	Swords:
	"""
	sword_basic_value = 0
	sword_basic_quant = 1
	sword_face_quant = 1
	sword_knight_mod = 10
	sword_knight_super = false
	sword_queen_mod = 1
	sword_king_mod = 3
	
	"""
	Major:
	"""
	major_quant = 1
	major_magician = 5
	major_empress = 1
	major_emperor = 1
	major_lovers = 4
	major_wheel_mult = 2
	major_wheel_charges = 5
	major_hanged_man = 2
	major_temperance = 100
	major_devil = 3
	major_star = 5
	major_moon = 2
	major_sun_star = 10
	major_sun_moon = 3
	major_judgement = 10
	
func reset_pack() -> void:
	pack_auto_draw = false
	pack_auto_draw_speed = 5.0
	pack_card_value = 1
	
func save() -> Dictionary:
	var save_data: Dictionary = {
		"tutorial_complete" = tutorial_complete,
		"clairvoyance" = clairvoyance,
		"packs" = packs,
		"gen_inversion_chance_mod" = gen_inversion_chance_mod,
		"gen_max_deck_size" = gen_max_deck_size,
		"gen_min_deck_size" = gen_min_deck_size,
	
		"cup_basic_value" = cup_basic_value,
		"cup_basic_quant" = cup_basic_quant,
		"cup_face_quant" = cup_face_quant,
		"cup_vessel_quant" = cup_vessel_quant,
		"cup_vessel_size" = cup_vessel_size,
		"cup_page_mod" = cup_page_mod,
		"cup_knight_mod" = cup_knight_mod,
		"cup_queen_mod" = cup_queen_mod,
	
		"wand_basic_value" = wand_basic_value,
		"wand_basic_quant" = wand_basic_quant,
		"wand_face_quant" = wand_face_quant,
		"wand_page_mod" = wand_page_mod,
		"wand_knight_mod" = wand_knight_mod,
		"wand_queen_mod" = wand_queen_mod,
		"wand_king_mod" = wand_king_mod,
			
		"pent_basic_value" = pent_basic_value,
		"pent_basic_quant" = pent_basic_quant,
		"pent_face_quant" = pent_face_quant,
		"pent_page_mod" = pent_page_mod,
		"pent_knight_uses" = pent_knight_uses,
		"pent_queen_uses" = pent_queen_uses,
		"pent_king_uses" = pent_king_uses,
		"pent_king_value" = pent_king_value,
			
		"sword_basic_value" = sword_basic_value,
		"sword_basic_quant" = sword_basic_quant,
		"sword_face_quant" = sword_face_quant,
		"sword_knight_mod" = sword_knight_mod,
		"sword_knight_super" = sword_knight_super,
		"sword_queen_mod" = sword_queen_mod,
		"sword_king_mod" = sword_king_mod,
			
		"major_quant" = major_quant,
		"major_magician" = major_magician,
		"major_empress" = major_empress,
		"major_emperor" = major_emperor,
		"major_lovers" = major_lovers,
		"major_wheel_mult" = major_wheel_mult,
		"major_wheel_charges" = major_wheel_charges,
		"major_temperance" = major_temperance,
		"major_devil" = major_devil,
		"major_star" = major_star,
		"major_moon" = major_moon,
		"major_sun_star" = major_sun_star,
		"major_sun_moon" = major_sun_moon,
		
		"pack_auto_draw" = pack_auto_draw,
		"pack_auto_draw_speed" = pack_auto_draw_speed,
		"pack_card_value" = pack_card_value
	}
	return save_data
	
func load_stats(dict: Dictionary) -> void:
	Events.emit_update_currency(dict["clairvoyance"])
	Events.emit_update_currency(dict["packs"], ID.CurrencyType.PACK)
	for stat in dict.keys():
		load_stat(stat, dict)
	
func load_stat(stat: String, dict: Dictionary) -> void:
	if stat in dict:
		set(stat, dict[stat])
		
func reset_game(type: ID.PrestigeLayer) -> void:
	if type >= ID.PrestigeLayer.DECK:
		reset_deck()
		Events.emit_update_currency(-clairvoyance)
	if type >= ID.PrestigeLayer.PACK:
		reset_pack()
		Events.emit_update_currency(-packs, ID.CurrencyType.PACK)
	if type >= ID.PrestigeLayer.ALL:
		tutorial_complete = false
