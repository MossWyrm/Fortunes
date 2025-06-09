extends suit_tracker
class_name swords_tracker

var combo: int
var combo_dir_flipped: bool
var combo_value: int = 1

var page_active: bool:
	get:
		return (page_pos_charges > 0 || page_neg_charges > 0)

var page_pos_charges: int
var page_neg_charges: int

var king_active: bool:
	get:
		return king_protection > 0 || king_destruction > 0
var king_protection: int = 0
var king_destruction: int = 0

func update(_value, flipped = false):
	if combo_dir_flipped == flipped:
		if king_destruction > 0:
			king_destruction -= 1
		else:	
			combo += combo_value
	else:
		if king_protection > 0:
			king_protection -= 1
		else:
			combo = 1
			combo_dir_flipped = flipped

func get_swords() -> int:
	return combo

func page_drawn(flipped):
	if flipped:
		page_neg_charges += Stats.wand_page_mod
	else:
		page_pos_charges += Stats.wand_page_mod

func queen_drawn(flipped):
	combo_value -= Stats.sword_queen_mod if flipped else -Stats.sword_queen_mod
	if combo_value < 0:
		combo_value = 0

func king_drawn(flipped):
	king_active = true
	if flipped:
		king_destruction = Stats.sword_king_mod
	else:
		king_protection = Stats.sword_king_mod

func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		combo = 1
		combo_value = 1
		page_pos_charges = 0
		page_neg_charges = 0
		king_protection = 0
		king_destruction = 0

	
func get_page_status() -> bool:
	return page_active

func use_page(value: int) -> int:
	if page_pos_charges > 0:
		return value ^ combo
	elif page_neg_charges > 0:
		return (value ^ combo)*-1
	else:
		return value
		

func get_display():
	var sword_dict: Dictionary = {
		"combo" = combo,
		"combo_value" = combo_value,
		"page_positive_charges" = page_pos_charges,
		"page_negative_charges" = page_neg_charges,
		"king_protection" = king_protection,
		"king_destruction" = king_destruction
		 }
	return sword_dict