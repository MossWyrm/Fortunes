extends HBoxContainer

@export var main: Node

var timepassed = 0
var cv_man: Node = null
var basic_box: Node
var queen_box: Node

func _ready():
	basic_box = self.get_child(0)
	queen_box = self.get_child(1)

func _update_pentacles_display():
	if(cv_man == null):
		cv_man = main.cv_manager
	var pent_dict = cv_man._get_pentacles()
	var pentacles_value = pent_dict["value"]
	var pentacles_uses = pent_dict["uses"]
	var pentacles_queen = pent_dict["queen"]

	if pentacles_value != int(basic_box.pentacles_value_display.text) || pentacles_uses != int(basic_box.pentacles_uses_display.text):
		basic_box.animator.play("icon_updating")

	basic_box.pentacles_value_display.text = str(pentacles_value)
	basic_box.pentacles_uses_display.text = str(pentacles_uses)

	if pentacles_queen != 0:
		queen_box.show()
		if pentacles_queen != int(queen_box.pentacles_queen_display.text):
			queen_box.animator.play("icon_updating")
		queen_box.pentacles_queen_display.text = str(pentacles_queen)
	else:
		queen_box.hide()

