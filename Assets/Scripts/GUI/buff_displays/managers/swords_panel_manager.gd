extends BuffManager

func _ready() -> void:
	displays["basic"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.SWORDS, ID.BuffType.GENERAL))
	displays["basic"].set_suit_and_type(DataStructures.SuitType.SWORDS, ID.BuffType.GENERAL)
	displays["page_positive"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.SWORDS, ID.BuffType.PAGE))
	displays["page_positive"].set_suit_and_type(DataStructures.SuitType.SWORDS, ID.BuffType.PAGE)
	displays["page_negative"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.SWORDS, ID.BuffType.PAGE))
	displays["page_negative"].set_suit_and_type(DataStructures.SuitType.SWORDS, ID.BuffType.PAGE)
	
	displays["king_positive"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.SWORDS, ID.BuffType.KING))
	displays["king_positive"].set_suit_and_type(DataStructures.SuitType.SWORDS, ID.BuffType.KING)
	displays["king_negative"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.SWORDS, ID.BuffType.KING))
	displays["king_negative"].set_suit_and_type(DataStructures.SuitType.SWORDS, ID.BuffType.KING)

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
	set_display(displays["basic"],
				dictionary["combo"] > 0,
				dictionary["combo"]
				)
	set_display(displays["page_positive"],
				dictionary["page_positive_charges"] > 0,
				dictionary["page_positive_charges"],
				get_panel_color(true)
				)
	set_display(displays["page_negative"],
				dictionary["page_negative_charges"] > 0,
				dictionary["page_negative_charges"],
				get_panel_color(false)
				)
	set_display(displays["king_positive"],
				dictionary["king_protection"] > 0,
				dictionary["king_protection"],
				get_panel_color(true)
				)
	set_display(displays["king_negative"],
				dictionary["king_destruction"] > 0,
				dictionary["king_destruction"],
				get_panel_color(false)
				)
