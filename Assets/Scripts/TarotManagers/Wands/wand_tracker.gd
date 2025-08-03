extends suit_tracker
class_name wand_tracker

# Tracks the state of the Wands suit (current value, knight/page charges, etc)

var current_value: float 	= 1
var page_active: bool:
	get:
		return page_charges > 0
var page_charges: int		= 0
var page_positive: bool		= false

var knight_active: bool:
	get:
		return knight_charges > 0
var knight_positive: bool 	= false
var knight_charges: int   	= 0

var value_mod: int        	= 0

# Updates the current value, clamped between 0.01 and 10000
func update(value, _flipped = false) -> void:
	print(value)
	current_value += value
	if current_value < 0.01:
		current_value = 0.01
	if current_value > 10000:
		current_value = 10000

# Returns the current value as a bonus multiplier
func bonus() -> float:
	return current_value

# Resets state on shuffle, unless shuffling safely
func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		value_mod = 0
		page_charges = 0
		knight_charges = 0
		current_value = 1

# Handles drawing a Page card	
func page_drawn(flipped: bool) -> void:
	page_positive = !flipped
	page_charges = Stats.wand_page_mod

# Handles skipping a Page effect if negative
func page_skip() -> bool:
	if page_active && !page_positive:
		page_charges -= 1
		return true
	return false
	
# Returns the number of page multiplications, then resets charges
func page_multiply() -> int:
	if !page_active:
		return 1
	var charges: int = page_charges
	page_charges = 0
	return charges

# Handles drawing a Knight card
func knight_drawn(flipped: bool) -> void:
	knight_positive = !flipped
	knight_charges = Stats.wand_knight_mod
	
# Triggers the knight effect, returns bonus or its inverse
func knight_trigger() -> float:
	knight_charges -= 1
	return bonus() if knight_positive else 1/bonus()
	
# Handles drawing a Queen card
func queen_drawn(flipped: bool) -> void:
	value_mod = (Stats.wand_queen_mod if !flipped else -Stats.wand_queen_mod) 

# Handles drawing a King card
func king_drawn(flipped) -> void:
	if !flipped:
		current_value = pow(current_value, 2)
	else:
		current_value = sqrt(current_value)
		
# Returns a dictionary of the current wand state for display
func get_display() -> Dictionary: 
	var dict: Dictionary = {
		"value" = current_value,
		"value_buff" = value_mod,
		"page_charges" = page_charges,
		"page_positive" = page_positive,
		"knight_charges" = knight_charges,
		"knight_positive" = knight_positive
		}
	return dict

# Restore state from backup (for simulation)
func restore_state(state: Dictionary) -> void:
	if state.has("value"):
		current_value = state["value"]
	if state.has("value_buff"):
		value_mod = state["value_buff"]
	if state.has("page_charges"):
		page_charges = state["page_charges"]
	if state.has("page_positive"):
		page_positive = state["page_positive"]
	if state.has("knight_charges"):
		knight_charges = state["knight_charges"]
	if state.has("knight_positive"):
		knight_positive = state["knight_positive"]
