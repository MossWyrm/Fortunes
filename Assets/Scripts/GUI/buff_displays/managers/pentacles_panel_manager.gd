extends BuffManager

@export var main: Node

var timepassed: int = 0
var cv_man: Node    = null
var basic_box: Node
var queen_box: Node

func _ready():
	basic_box = self.get_child(0)
	queen_box = self.get_child(1)

func update_display(dictionary: Dictionary):
	"""
	--- Dictionary Values ---
	"value" = current_pentacles
	"uses" = charges
	"queen_uses" = queen_charges
	"queen_inverted" = queen_inverted
	"blocked" = blocked
	"""
	var pent_dict : Dictionary = dictionary
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

