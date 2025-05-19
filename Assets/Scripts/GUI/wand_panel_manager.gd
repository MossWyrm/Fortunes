extends HBoxContainer

@export var main: Node

var timepassed = 0
var cv_man: Node = null
var child: Node

func _ready():
	child = self.get_child(0)

func _update_wand_display():
	if child == null:
		child = self.get_child(0)
	if(cv_man == null):
		cv_man = main.cv_manager
	var wand_value = cv_man._get_wands()
	if wand_value != int(child.wand_value_display.text):
		child.animator.play("icon_updating")
	child.wand_value_display.text = str(wand_value)

