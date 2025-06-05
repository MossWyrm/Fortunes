extends BuffManager

@export var main: Node

var timepassed = 0
var display: Node:
	get:
		if display == null:
			display = get_child(0)
		return display

func update_display(dictionary: Dictionary):
	"""
	--- Dictionary Values ---
	"value" = current_value,
	"value_buff" = value_mod,
	"page_charges" = page_charges,
	"page_positive" = page_positive,
	"knight_charges" = knight_charges,
	"knight_positive" = knight_positive
	"""
	var wand_value: Dictionary = dictionary
	if wand_value["value"] != float(display.wand_value_display.text):
		display.animator.play("icon_updating")
	display.wand_value_display.text = str(wand_value)

