extends card_calc
class_name pentacles_calc

@onready var tracker: pentacles_tracker = get_child(0)

func _value_modifier(value, flipped = false) -> int:
	return -value if flipped else value

func _basic(value, flipped = false) -> int:
	var val: int = _value_modifier(value, flipped)
	tracker.update(val, false)
	return tracker.current_pentacles+val

func _page(flipped = false) -> int:
	var val: int = _value_modifier(11, flipped)
	tracker.update(val, false)
	tracker.current_pentacles = roundi(tracker.current_pentacles * (Stats.pent_page_negative if flipped else Stats.pent_page_positive))
	return tracker.current_pentacles + val
	
func _knight(flipped = false) -> int:
	var val: int = _value_modifier(12, flipped)
	tracker.update(val, false)
	tracker.adjust_charges(Stats.pent_knight_uses * ( -1 if flipped else 1))
	return tracker.current_pentacles + val

func _queen(flipped = false) -> int:
	tracker.update_queen_pentacles(flipped)
	var val: int = _value_modifier(13, flipped)
	tracker.update(val, false)
	return tracker.current_pentacles + val

func _king(flipped = false) -> int:
	var val: int = _value_modifier(14, flipped)
	if flipped:
		tracker.adjust_charges(0)
		tracker.update(0,false,true)
		tracker.blocked = true
	else:
		tracker.adjust_charges(Stats.pent_king_uses)
		tracker.update(Stats.pent_king_value, false, false)
		
	return tracker.current_pentacles + val
	
func use_pentacles(value) -> int:
	return tracker.use_pentacles(value)

func get_display() -> Dictionary:
	if tracker == null:
		tracker = get_child(0)
	return tracker.get_display()

func check_queen_pent(flipped) -> bool:
	return tracker.use_queen_pentacles(flipped)