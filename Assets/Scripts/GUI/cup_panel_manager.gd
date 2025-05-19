extends Node

@export var main: Node

var timepassed = 0
var cv_man: Node = null

func _update_cup_display():
	if(cv_man == null):
		cv_man = main.cv_manager
	var cup_dict = cv_man._get_cups()
	if cup_dict.size() < self.get_child_count():
		var x = self.get_child_count()
		while x > cup_dict.size():
			self.get_child(x-1).queue_free()
			x -= 1
	var y = cup_dict.size()
	var z = 0
	while z < y:
		if(z+1 > self.get_child_count()):
			var scenetoload = load("res://Assets/Scenes/cup_panel.tscn")
			var cup_counter = scenetoload.instantiate()
			if(cup_counter.get_parent()):
				cup_counter.get_parent().remove_child(cup_counter)
			add_child(cup_counter)
		var child = self.get_child(z)
		var keyname = "cup_"+str(z+1)
		if cup_dict[str(keyname)] != int(child.cup_value_display.text):
			child.animator.play("icon_updating")
		child.cup_value_display.text = str(cup_dict[str(keyname)])
		z += 1

