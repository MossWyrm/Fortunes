extends suit_tracker
class_name cup_tracker

var cup_scene = preload("res://Assets/Scripts/TarotManagers/Cups/cup.gd")

func _init():
	if self.get_child_count() < 1:
		add_cup()

func update(value, _flipped = false):
	for N in self.get_children():
		N.cup_current_value += value
		if N.cup_current_value > Stats.cup_max_size + Stats.cup_max_size_modifier:
			N.cup_current_value = Stats.cup_max_size + Stats.cup_max_size_modifier
		if N.cup_current_value < 0:
			N.cup_current_value = 0
		

func add_cup():
	if get_child_count() >= Stats.cup_max_quant:
		pass
	var child = cup_scene.new()
	var child_num = self.get_child_count()
	var child_name = "cup_" + str(child_num + 1)
	child.name = child_name
	if child.get_parent():
		child.get_parent().remove_child(child)
	child.cup_number = child_num+1
	add_child(child)

func remove_cup() -> void:
	if(self.get_child_count() <= 1):
		self.get_child(0).cup_current_value = 0
	else:
		var index = self.get_child_count()-1
		var child = self.get_child(index)
		child.queue_free()

func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		Stats.cup_max_size_modifier = 0
		for N in self.get_children():
			remove_cup()

func bonus() -> int:
	var totalValue: int = 0
	for cup in self.get_children():
		totalValue += cup.cup_current_value
	return totalValue

func get_cups() -> Dictionary:
	var cup_dict: Dictionary = {}
	for N in self.get_children():
		var cup_dict_name = "cup_"+ str(N.cup_number)
		cup_dict[cup_dict_name] = N.cup_current_value
	return cup_dict

func empty_cups():
	for N in self.get_children():
		N.cup_current_value = 0

func fill_cups():
	for N in self.get_children():
		N.cup_current_value = Stats.cup_max_size + Stats.cup_max_size_modifier