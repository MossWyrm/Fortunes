extends BuffManager

@export var main: Node

var basic_box: Node
var page_box: Node
var king_box: Node

func _ready():
	basic_box = self.get_child(0)
	# page_box = self.get_child(1)
	# king_box = self.get_child(2)

func update_display(dictionary: Dictionary):
	"""
	--- Dictionary Values ---
	"combo" = combo,
	"combo_value" = combo_value,
	"page_positive_charges" = page_pos_charges,
	"page_negative_charges" = page_neg_charges,
	"king_protection" = king_protection,
	"king_destruction" = king_destruction
	"""
	var sword_dict = dictionary
	var sword_value = sword_dict["combo"]
	var sword_power = sword_dict["combo_value"]
	var sword_page = sword_dict["page"]
	var sword_page_positive = sword_dict["page_positive"]
	var sword_king = sword_dict["king"]
	var sword_king_protection = sword_dict["king_protection"]
	var sword_king_destruction = sword_dict["king_destruction"]

	if sword_value != int(basic_box.swords_value_display.text) || sword_power != int(basic_box.swords_power_display.text):
		basic_box.animator.play("icon_updating")

	basic_box.swords_value_display.text = str(sword_value)
	basic_box.swords_power_display.text = str(sword_power)

	# if sword_page:
	# 	page_box.show()
	# 	page_box.animator.play("icon_updating")
	# 	# page_box. ._update_text(pentacles_queen)
	# else:
	# 	page_box.hide()

