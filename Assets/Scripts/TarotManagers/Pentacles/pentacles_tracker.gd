extends suit_tracker
class_name pentacles_tracker

var current_pentacles: int 	= 0
var charges: int         	= 0

var queen_inverted: bool 	= false
var queen_charges: int   	= 0
var blocked: bool 			= false


func update(value, _flipped = false, override = false) -> void:
	if blocked:
		return
	if override:
		current_pentacles = value
	else:
		current_pentacles += value
	if current_pentacles <=0:
		current_pentacles = 0
		
func adjust_charges(value, override = false) -> void:
	if override:
		charges = value
	else:
		charges += value
	if charges <=0:
		_reset(false)

func draw_page(flipped) -> void:
	var mod = (1 - Stats.pent_page_mod) if flipped else (1+ Stats.pent_page_mod) 
	current_pentacles = roundi(current_pentacles * mod)
	
func update_queen_pentacles(flipped) -> void:
	if flipped:
		queen_inverted = true
	else:
		queen_inverted = false
	queen_charges += Stats.pent_queen_uses
	
func use_queen_pentacles(flipped) -> bool:
	if queen_charges <= 0:
		return false
	if flipped != queen_inverted:
		queen_charges -= 1
		return true
	return false
		
func use_pentacles(value) -> int:
	var output_value: int = value
	if 0 - value > current_pentacles:
		output_value = value + current_pentacles
	else:
		output_value = 0
	if charges >= 1:
		charges -=1
		return output_value
	current_pentacles += value
	if current_pentacles <= 0:
		current_pentacles = 0
	return output_value

func _reset(queenincluded) -> void:
	current_pentacles = 0
	charges = 0
	if queenincluded:
		queen_inverted = false
		queen_charges = 0

func shuffle(safely) -> void:
	blocked = false
	if safely == true:
		return
	else:
		_reset(true)

func get_display() -> Dictionary:
	var pent_dict: Dictionary = {}

	pent_dict["value"] = current_pentacles
	pent_dict["uses"] = charges
	pent_dict["queen_uses"] = queen_charges
	pent_dict["queen_inverted"] = queen_inverted
	pent_dict["blocked"] = blocked

	return pent_dict