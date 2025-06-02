extends suit_tracker
class_name swords_tracker

var sword_count: int
var upright: bool
var page_active: bool
var page_positive: bool
var sword_value: int = 1
var king_active: bool
var king_protection: int = 0
var king_destruction: int = 0

func update(_value, flipped = false):
	if upright == !flipped:
		if king_active && king_destruction > 0:
			king_destruction -= 1
		else:
			sword_count +=1
	else:
		if king_active && king_protection > 0:
			king_protection -= 1
		else:
			sword_count = 1
			upright = !flipped
	if king_destruction == 0 && king_protection == 0:
		king_active = false

func get_swords():
	return sword_count

func shuffle(safely):
	if safely == true:
		return
	else:
		sword_count = 1
		sword_value = 1

func page_triggered(flipped):
	page_active = true
	page_positive = !flipped

func use_page():
	page_active = false

func get_page_status() -> bool:
	return page_active

func page_type_upright():
	return page_positive

func queen_triggered(flipped):
	sword_value -= 1 if flipped else -1

func king_triggered(flipped):
	king_active = true
	if flipped:
		king_destruction = sword_count
	else:
		king_protection = sword_count

func get_sword_display():
	var sword_dict: Dictionary = {}
	sword_dict["combo"] = sword_count
	sword_dict["combo_value"] = sword_value
	sword_dict["page"] = page_active
	sword_dict["page_positive"] = page_positive
	sword_dict["king"] = king_active
	sword_dict["king_protection"] = king_protection
	sword_dict["king_destruction"] = king_destruction
	return sword_dict