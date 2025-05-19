extends Node

func _init():
	if self.get_child_count() < 1:
		_add_pentacle_tracker()

func _update_pentacle(value, uses):
	for N in self.get_children():
		if uses:
			N.pentacles_uses += value
			if N.pentacles_uses <= 0:
				_reset_value(false)
		else:
			N.pentacles_current_value += value
			if N.pentacles_current_value <=0:
				N.pentacles_current_value = 0

func _add_pentacle_tracker():
	var child = Node.new()
	var child_name = "pentacle_tracker"
	child.name = child_name
	child.script = load("res://Assets/Scripts/TarotManagers/Pentacles/pentacle.gd")
	if child.get_parent():
		child.get_parent().remove_child(child)
	child.pentacles_current_value = 1
	child.pentacles_uses = 1
	child.pentacles_queen_protect = 0
	add_child(child)

func _get_pentacles():
	return self.get_child(0).pentacles_current_value

func _get_pentacles_display():
	var pent_dict = {}
	var child = self.get_child(0)

	pent_dict["value"] = child.pentacles_current_value
	pent_dict["queen"] = child.pentacles_queen_protect
	pent_dict["uses"] = child.pentacles_uses

	return pent_dict

func _check_queen_pentacles(flipped):
	if flipped:
		return self.get_child(0).pentacles_queen_protect > 0
	else:
		return self.get_child(0).pentacles_queen_protect < 0

func _update_queen_pentacles(val):
	self.get_child(0).pentacles_queen_protect += val

func _use_queen_pentacles():
	var queenNode = self.get_child(0)
	if queenNode.pentacles_queen_protect > 0:
		queenNode.pentacles_queen_protect -=1
	elif queenNode.pentacles_queen_protect < 0:
		queenNode.pentacles_queen_protect +=1
	else:
		print("Invalid use of queen pentacles")


func _use_pentacles(value):
	var child = self.get_child(0)
	var output_value = 0
	if 0 - value > child.pentacles_current_value:
		output_value = value + child.pentacles_current_value
		if child.pentacles_uses >1:
			child.pentacles_uses -=1
		else:
			child.pentacles_current_value = 0
	else:
		output_value = 0
		if child.pentacles_uses >1:
			child.pentacles_uses -=1
		else:
			child.pentacles_current_value += value
		
	return output_value	

func _replace_pentacles(value):
	self.get_child(0).pentacles_current_value = value

func _reset_value(queenincluded):
	var child = self.get_child(0)
	child.pentacles_current_value = 0
	child.pentacles_uses = 1
	if queenincluded:
		child.pentacles_queen_protect = 0

func _shuffle(safely):
	if safely == true:
		return
	else:
		_reset_value(true)