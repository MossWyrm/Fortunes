extends suit_tracker
class_name pentacles_tracker

# Tracks the state of the Pentacles suit (current value, charges, queen state, etc)

var current_pentacles: int 	= 0
var charges: int         	= 0

var queen_inverted: bool 	= false
var queen_charges: int   	= 0
var blocked: bool 			= false

# Updates pentacles value, with optional override
func update(value, _flipped = false, override = false) -> void:
	if blocked:
		return
	if override:
		current_pentacles = value
	else:
		current_pentacles += value
	if current_pentacles <=0:
		current_pentacles = 0
		
# Adjusts the number of pentacle charges
func adjust_charges(value, override = false) -> void:
	if override:
		charges = value
	else:
		charges += value
	if charges <=0:
		_reset(false)

# Handles drawing a Page card for Pentacles
func draw_page(flipped) -> void:
	var mod = (1 - Stats.pent_page_mod) if flipped else (1+ Stats.pent_page_mod) 
	current_pentacles = roundi(current_pentacles * mod)
	
# Updates queen pentacles state and charges
func update_queen_pentacles(flipped) -> void:
	if flipped:
		queen_inverted = true
	else:
		queen_inverted = false
	queen_charges += Stats.pent_queen_uses
	
# Checks and uses queen pentacles if appropriate
func use_queen_pentacles(flipped) -> bool:
	if queen_charges <= 0:
		return false
	if flipped != queen_inverted:
		queen_charges -= 1
		return true
	return false
		
# Uses pentacles to absorb negative value, or applies charges
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

# Resets pentacles state, optionally including queen state
func _reset(queenincluded) -> void:
	current_pentacles = 0
	charges = 0
	if queenincluded:
		queen_inverted = false
		queen_charges = 0

# Resets state on shuffle, unless shuffling safely
func shuffle(safely) -> void:
	blocked = false
	if safely == true:
		return
	else:
		_reset(true)

# Returns a dictionary of the current pentacles state for display
func get_display() -> Dictionary:
	var pent_dict: Dictionary = {}

	pent_dict["value"] = current_pentacles
	pent_dict["uses"] = charges
	pent_dict["queen_uses"] = queen_charges
	pent_dict["queen_inverted"] = queen_inverted
	pent_dict["blocked"] = blocked

	return pent_dict

# Restore state from backup (for simulation)
func restore_state(state: Dictionary) -> void:
	if state.has("value"):
		current_pentacles = state["value"]
	if state.has("uses"):
		charges = state["uses"]
	if state.has("queen_uses"):
		queen_charges = state["queen_uses"]
	if state.has("queen_inverted"):
		queen_inverted = state["queen_inverted"]
	if state.has("blocked"):
		blocked = state["blocked"]