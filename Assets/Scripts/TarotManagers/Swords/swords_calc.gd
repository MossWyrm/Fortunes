extends card_calc
class_name swords_calc

@onready var tracker: swords_tracker = get_child(0)

# Applies value modifications and page effects
func _value_modifier(value, flipped = false) -> int:
	var updated_value: int = -value if flipped else value
	updated_value = _use_page(updated_value)
	return updated_value

# Basic card calculation for Swords
func _basic(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	return tracker.get_swords()*val

# Page card calculation for Swords
func _page(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.page_drawn(flipped)
	return tracker.get_swords()*val

# Knight card calculation for Swords, adds/removes cards based on combo
func _knight(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	var deck_manager = GM.deck_manager
	for x in tracker.get_swords():
		if flipped:
			deck_manager.remove_lower_than(Stats.sword_knight_mod, Stats.sword_knight_super)
		else:
			deck_manager.add_lower_than(Stats.sword_knight_mod, Stats.sword_knight_super)
		
	return tracker.get_swords()*val

# Queen card calculation for Swords
func _queen(flipped = false) -> int:
	tracker.queen_drawn(flipped)
	var val: int = _value_modifier(card_value, flipped)
	return tracker.get_swords()*val

# King card calculation for Swords
func _king(flipped = false) -> int:
	var val : int = _value_modifier(card_value, flipped)
	tracker.king_drawn(flipped)
	return tracker.get_swords()*val

# Updates sword state for a new card
func update_swords(flipped) -> void:
	if tracker == null:
		tracker = get_child(0)
	tracker.update(0,flipped)

# Applies page effect if active
func _use_page(value: int) -> int:
	if !tracker.get_page_status():
		return value
	return tracker.use_page(value)
	
# Returns display dictionary for Swords
func get_display() -> Dictionary:
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_display()

# Returns base value for Swords
func get_base_value(value: int) -> int:
	return value + Stats.sword_basic_value
	