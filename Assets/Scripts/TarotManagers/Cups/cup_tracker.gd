extends Node


func _init():
	if self.get_child_count() < 1:
		_add_cup()

func _update_cup(value):
	for N in self.get_children():
		N.cup_current_value += value
		if N.cup_current_value > Stats.cup_max_size:
			N.cup_current_value = Stats.cup_max_size
		if N.cup_current_value < 0:
			N.cup_current_value = 0
		

func _add_cup():
	if get_child_count() >= Stats.cup_max_quant:
		pass
	var child = Node.new()
	var child_num = self.get_child_count()
	var child_name = "cup_" + str(child_num + 1)
	child.name = child_name
	child.script = load("res://Assets/Scripts/TarotManagers/Cups/cup.gd")
	if child.get_parent():
		child.get_parent().remove_child(child)
	child.cup_number = child_num+1
	add_child(child)

func _remove_cup():
	if(self.get_child_count() <= 1):
		self.get_child(0).cup_current_value = 0
	else:
		var index = self.get_child_count()-1
		var child = self.get_child(index)
		child.queue_free()

func _shuffle(safely):
	if safely == true:
		return
	else:
		for N in self.get_children():
			_remove_cup()

func _cup_bonus():
	var totalValue = 0
	for cup in self.get_children():
		totalValue += cup.cup_current_value
	return totalValue

func _get_cups():
	var cup_dict = {}
	for N in self.get_children():
		var cup_dict_name = "cup_"+ str(N.cup_number)
		cup_dict[cup_dict_name] = N.cup_current_value
	return cup_dict

func _empty_cups():
	for N in self.get_children():
		N.cup_current_value = 0

func _fill_cups():
	for N in self.get_children():
		N.cup_current_value = Stats.cup_max_size