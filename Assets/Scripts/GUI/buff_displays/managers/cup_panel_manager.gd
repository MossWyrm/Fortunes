extends BuffManager

@export var main: Node

var timepassed: int = 0

func update_display(dictionary: Dictionary) -> void:
	"""
	
	--- Dictionary Values ---
	1 = cup_value
	2 = cup_value
	...
	...
	
	"""
	var cup_dict: Dictionary = dictionary
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

