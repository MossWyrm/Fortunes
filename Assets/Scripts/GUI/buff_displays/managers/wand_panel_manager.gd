extends BuffManager


func _ready() -> void:
	displays["basic"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.WANDS, ID.BuffType.GENERAL))
	displays["basic"].set_suit_and_type(DataStructures.SuitType.WANDS, ID.BuffType.GENERAL)
	displays["page"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.WANDS, ID.BuffType.PAGE))
	displays["page"].set_suit_and_type(DataStructures.SuitType.WANDS, ID.BuffType.PAGE)
	displays["knight"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.WANDS, ID.BuffType.KNIGHT))
	displays["knight"].set_suit_and_type(DataStructures.SuitType.WANDS, ID.BuffType.KNIGHT)
	
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
	set_display(displays["basic"], 
				dictionary["value"] > 0.0, 
				dictionary["value"]
				)
	set_display(displays["page"],
				dictionary["page_charges"] > 0,
				dictionary["page_charges"],
				get_panel_color(dictionary["page_positive"])
				)
	set_display(displays["knight"],
				dictionary["knight_charges"] > 0,
				dictionary["knight_charges"],
				get_panel_color(dictionary["knight_positive"])
	)
