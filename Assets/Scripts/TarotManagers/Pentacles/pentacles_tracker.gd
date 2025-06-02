extends suit_tracker
class_name pentacles_tracker

var pentacle := preload("res://Assets/Scripts/TarotManagers/Pentacles/pentacle.gd")
var tracker
var current_pentacles: int: 
	get:
		return tracker.pentacles_current_value
	set(value):
		tracker.pentacles_current_value = value
var blocked: bool = false
var queen_inverted = false

func _init():
	if self.get_child_count() < 1:
		_add_pentacle_tracker()

func update(value, _flipped = false, override = false):
	if blocked:
		return
	if override:
		tracker.pentacles_current_value = value
	else: 
		tracker.pentacles_current_value += value
	if tracker.pentacles_current_value <=0:
		tracker.pentacles_current_value = 0
		
func adjust_charges(value, override = false) -> void:
	if override:
		tracker.pentacles_uses = value
	else:
		tracker.pentacles_uses += value
	if tracker.pentacles_uses <=0:
		_reset(false)

func _add_pentacle_tracker():
	var child = pentacle.new()
	child.name = "pentacle_tracker"
	add_child(child)
	tracker = child

func get_pentacles_display():
	var pent_dict = {}

	pent_dict["value"] = tracker.pentacles_current_value
	pent_dict["queen"] = tracker.pentacles_queen_protect
	pent_dict["uses"] = tracker.pentacles_uses

	return pent_dict

func update_queen_pentacles(flipped):
	if flipped:
		queen_inverted = true
	else:
		queen_inverted = false
	tracker.pentacles_queen_protect += 1
	
func use_queen_pentacles(flipped) -> bool:
	if tracker.pentacles_queen_protect <= 0:
		return false
	if flipped && !queen_inverted:
		tracker.pentacles_queen_protect -= 1
		return true
	elif !flipped && queen_inverted:
		tracker.pentacles_queen_protect -=1
		return true
	return false
		
func use_pentacles(value) -> int:
	var output_value: int = value
	if tracker.pentacles_uses >=1:
		tracker.pentacles_uses -=1
		if 0 - value > tracker.pentacles_current_value:
			output_value = value + tracker.pentacles_current_value
		else:
			output_value = 0
		if tracker.pentacles_uses <= 0:
			_reset(false)
	return output_value

func _reset(queenincluded):
	tracker.pentacles_current_value = 0
	tracker.pentacles_uses = 0
	if queenincluded:
		queen_inverted = false
		tracker.pentacles_queen_protect = 0

func shuffle(safely):
	blocked = false
	if safely == true:
		return
	else:
		_reset(true)