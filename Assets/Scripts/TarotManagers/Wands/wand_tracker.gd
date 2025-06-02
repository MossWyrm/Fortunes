extends suit_tracker
class_name wand_tracker

func _init():
	if self.get_child_count() < 1:
		_create_wand_tracker()

func update(value, _flipped = false):
	var child = self.get_child(0)
	# if value < 0:
	# 	child.wand_current_value /= (0-value)
	# else:
	child.wand_current_value += value
	
	if child.wand_current_value < 0.01:
		child.wand_current_value = 0.01
	
	if child.wand_current_value > 10000:
		child.wand_current_value = 10000

func _create_wand_tracker():
	var child = Node.new()
	var child_name = "wand_tracker"
	child.name = child_name
	child.script = load("res://Assets/Scripts/TarotManagers/Wands/wand.gd")
	if child.get_parent():
		child.get_parent().remove_child(child)
	child.wand_current_value = 1
	add_child(child)

func _wand_bonus():
	return self.get_child(0).wand_current_value

func _shuffle(safely):
	if safely == true:
		return
	else:
		self.get_child(0).wand_current_value = 1

func _king_wand_mod(flipped):
	var child = self.get_child(0)
	if !flipped:
		child.wand_current_value *= child.wand_current_value
	else:
		child.wand_current_value *= 1/child.wand_current_value

