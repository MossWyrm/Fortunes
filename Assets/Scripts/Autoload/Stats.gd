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
var major_high_priestess: int = 3 #IMPLEMENTED
var major_hierophant: int = 2 #IMPLEMENTED
var major_strength: int = 5 #IMPLEMENTED
var major_justice: int = 1 #IMPLEMENTED
var major_death: int = 1 #IMPLEMENTED

"""
Packs:
"""
var pack_auto_draw: bool = false
var pack_auto_draw_speed: float = 5.0
var pack_card_value: int = 1

func _ready() -> void:
	Events.reset.connect(reset_game)
	
	# Connect to new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state:
		# Sync with new architecture
		_sync_with_new_architecture()

func _sync_with_new_architecture():
	var game_manager = get_node("/root/GameManager")
	if not game_manager or not game_manager.game_state:
		return
	
	var game_stats = game_manager.game_state.game_stats
	var game_config = game_manager.game_state.game_config
	
	# Sync general stats
	clairvoyance = game_stats.clairvoyance
	packs = game_stats.packs
	tutorial_complete = game_stats.tutorial_complete
	gen_inversion_chance_mod = game_stats.gen_inversion_chance_mod
	gen_max_deck_size = game_stats.gen_max_deck_size
	gen_min_deck_size = game_stats.gen_min_deck_size
	
	# Sync suit-specific stats
	_sync_cup_stats(game_stats.cup_stats)
	_sync_wand_stats(game_stats.wand_stats)
	_sync_pentacle_stats(game_stats.pentacle_stats)
	_sync_sword_stats(game_stats.sword_stats)
	_sync_major_stats(game_stats.major_stats)
	
	# Sync pack stats
	pack_auto_draw = game_stats.pack_auto_draw
	pack_auto_draw_speed = game_stats.pack_auto_draw_speed
	pack_card_value = game_stats.pack_card_value

func _sync_cup_stats(cup_stats):
	cup_basic_value = cup_stats.basic_value
	cup_basic_quant = cup_stats.basic_quant
	cup_face_quant = cup_stats.face_quant
	cup_vessel_size = cup_stats.vessel_size
	cup_vessel_quant = cup_stats.vessel_quant
	cup_page_mod = cup_stats.page_mod
	cup_knight_mod = cup_stats.knight_mod
	cup_queen_mod = cup_stats.queen_mod

func _sync_wand_stats(wand_stats):
	wand_basic_value = wand_stats.basic_value
	wand_basic_quant = wand_stats.basic_quant
	wand_face_quant = wand_stats.face_quant
	wand_page_mod = wand_stats.page_mod
	wand_knight_mod = wand_stats.knight_mod
	wand_queen_mod = wand_stats.queen_mod
	wand_king_mod = wand_stats.king_mod

func _sync_pentacle_stats(pentacle_stats):
	pent_basic_value = pentacle_stats.basic_value
	pent_basic_quant = pentacle_stats.basic_quant
	pent_face_quant = pentacle_stats.face_quant
	pent_page_mod = pentacle_stats.page_mod
	pent_knight_uses = pentacle_stats.knight_uses
	pent_queen_uses = pentacle_stats.queen_uses
	pent_king_uses = pentacle_stats.king_uses
	pent_king_value = pentacle_stats.king_value

func _sync_sword_stats(sword_stats):
	sword_basic_value = sword_stats.basic_value
	sword_basic_quant = sword_stats.basic_quant
	sword_face_quant = sword_stats.face_quant
	sword_knight_mod = sword_stats.knight_mod
	sword_knight_super = sword_stats.knight_super
	sword_queen_mod = sword_stats.queen_mod
	sword_king_mod = sword_stats.king_mod

func _sync_major_stats(major_stats):
	major_quant = major_stats.quant
	major_magician = major_stats.magician
	major_empress = major_stats.empress
	major_emperor = major_stats.emperor
	major_lovers = major_stats.lovers
	major_wheel_mult = major_stats.wheel_mult
	major_wheel_charges = major_stats.wheel_charges
	major_hanged_man = major_stats.hanged_man
	major_temperance = major_stats.temperance
	major_devil = major_stats.devil
	major_star = major_stats.star
	major_moon = major_stats.moon
	major_sun_star = major_stats.sun_star
	major_sun_moon = major_stats.sun_moon
	major_judgement = major_stats.judgement
	major_high_priestess = major_stats.high_priestess
	major_hierophant = major_stats.hierophant
	major_strength = major_stats.strength
	major_justice = major_stats.justice
	major_death = major_stats.death

func card_max_quant(card: DataStructures.Card) -> int:
	if card.card_suit == DataStructures.SuitType.CUPS:
		if card.card_id_num <= 110:
			return cup_basic_quant
		return cup_face_quant
	if card.card_suit == DataStructures.SuitType.WANDS:
		if card.card_id_num <= 210:
			return wand_basic_quant
		return wand_face_quant
	if card.card_suit == DataStructures.SuitType.PENTACLES:
		if card.card_id_num <= 310:
			return pent_basic_quant
		return pent_face_quant
	if card.card_suit == DataStructures.SuitType.SWORDS:
		if card.card_id_num <= 410:
			return sword_basic_quant
		return sword_face_quant
	if card.card_suit == DataStructures.SuitType.MAJOR:
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
	major_high_priestess = 3
	major_hierophant = 2
	major_strength = 5
	major_justice = 1
	major_death = 1
	
	# Sync with new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state:
		_sync_new_architecture()

func reset_pack() -> void:
	pack_auto_draw = false
	pack_auto_draw_speed = 5.0
	pack_card_value = 1
	
	# Sync with new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state:
		_sync_new_architecture()

func _sync_new_architecture():
	var game_manager = get_node("/root/GameManager")
	if not game_manager or not game_manager.game_state:
		return
	
	var game_stats = game_manager.game_state.game_stats
	
	# Sync general stats
	game_stats.clairvoyance = clairvoyance
	game_stats.packs = packs
	game_stats.tutorial_complete = tutorial_complete
	game_stats.gen_inversion_chance_mod = gen_inversion_chance_mod
	game_stats.gen_max_deck_size = gen_max_deck_size
	game_stats.gen_min_deck_size = gen_min_deck_size
	
	# Sync suit-specific stats
	_sync_new_cup_stats(game_stats.cup_stats)
	_sync_new_wand_stats(game_stats.wand_stats)
	_sync_new_pentacle_stats(game_stats.pentacle_stats)
	_sync_new_sword_stats(game_stats.sword_stats)
	_sync_new_major_stats(game_stats.major_stats)
	
	# Sync pack stats
	game_stats.pack_auto_draw = pack_auto_draw
	game_stats.pack_auto_draw_speed = pack_auto_draw_speed
	game_stats.pack_card_value = pack_card_value

func _sync_new_cup_stats(cup_stats):
	cup_stats.basic_value = cup_basic_value
	cup_stats.basic_quant = cup_basic_quant
	cup_stats.face_quant = cup_face_quant
	cup_stats.vessel_size = cup_vessel_size
	cup_stats.vessel_quant = cup_vessel_quant
	cup_stats.page_mod = cup_page_mod
	cup_stats.knight_mod = cup_knight_mod
	cup_stats.queen_mod = cup_queen_mod

func _sync_new_wand_stats(wand_stats):
	wand_stats.basic_value = wand_basic_value
	wand_stats.basic_quant = wand_basic_quant
	wand_stats.face_quant = wand_face_quant
	wand_stats.page_mod = wand_page_mod
	wand_stats.knight_mod = wand_knight_mod
	wand_stats.queen_mod = wand_queen_mod
	wand_stats.king_mod = wand_king_mod

func _sync_new_pentacle_stats(pentacle_stats):
	pentacle_stats.basic_value = pent_basic_value
	pentacle_stats.basic_quant = pent_basic_quant
	pentacle_stats.face_quant = pent_face_quant
	pentacle_stats.page_mod = pent_page_mod
	pentacle_stats.knight_uses = pent_knight_uses
	pentacle_stats.queen_uses = pent_queen_uses
	pentacle_stats.king_uses = pent_king_uses
	pentacle_stats.king_value = pent_king_value

func _sync_new_sword_stats(sword_stats):
	sword_stats.basic_value = sword_basic_value
	sword_stats.basic_quant = sword_basic_quant
	sword_stats.face_quant = sword_face_quant
	sword_stats.knight_mod = sword_knight_mod
	sword_stats.knight_super = sword_knight_super
	sword_stats.queen_mod = sword_queen_mod
	sword_stats.king_mod = sword_king_mod

func _sync_new_major_stats(major_stats):
	major_stats.quant = major_quant
	major_stats.magician = major_magician
	major_stats.empress = major_empress
	major_stats.emperor = major_emperor
	major_stats.lovers = major_lovers
	major_stats.wheel_mult = major_wheel_mult
	major_stats.wheel_charges = major_wheel_charges
	major_stats.hanged_man = major_hanged_man
	major_stats.temperance = major_temperance
	major_stats.devil = major_devil
	major_stats.star = major_star
	major_stats.moon = major_moon
	major_stats.sun_star = major_sun_star
	major_stats.sun_moon = major_sun_moon
	major_stats.judgement = major_judgement
	major_stats.high_priestess = major_high_priestess
	major_stats.hierophant = major_hierophant
	major_stats.strength = major_strength
	major_stats.justice = major_justice
	major_stats.death = major_death

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
		"major_high_priestess" = major_high_priestess,
		"major_hierophant" = major_hierophant,
		"major_strength" = major_strength,
		"major_justice" = major_justice,
		"major_hanged_man" = major_hanged_man,
		"major_death" = major_death,
		
		"pack_auto_draw" = pack_auto_draw,
		"pack_auto_draw_speed" = pack_auto_draw_speed,
		"pack_card_value" = pack_card_value
	}
	return save_data
	
func load_stats(dict: Dictionary) -> void:
	Events.emit_update_currency(dict["clairvoyance"])
	Events.emit_update_currency(dict["packs"], DataStructures.CurrencyType.PACK)
	for stat in dict.keys():
		load_stat(stat, dict)
	
	# Sync with new architecture if available
	var game_manager = get_node("/root/GameManager")
	if game_manager and game_manager.game_state:
		_sync_new_architecture()
	
func load_stat(stat: String, dict: Dictionary) -> void:
	if stat in dict:
		set(stat, dict[stat])
		
func reset_game(type: DataStructures.GameLayer) -> void:
	if type >= DataStructures.GameLayer.DECK:
		reset_deck()
		Events.emit_update_currency(-clairvoyance)
	if type >= DataStructures.GameLayer.PACK:
		reset_pack()
		Events.emit_update_currency(-packs, DataStructures.CurrencyType.PACK)
	if type >= DataStructures.GameLayer.ALL:
		tutorial_complete = false
