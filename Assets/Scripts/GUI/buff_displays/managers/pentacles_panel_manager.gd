extends BuffManager

func _ready():
	displays["basic"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.PENTACLES, ID.BuffType.GENERAL))
	displays["basic"].set_suit_and_type(DataStructures.SuitType.PENTACLES, ID.BuffType.GENERAL)
	displays["uses"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.PENTACLES, ID.BuffType.GENERAL))
	displays["uses"].set_suit_and_type(DataStructures.SuitType.PENTACLES, ID.BuffType.GENERAL)
	displays["queen"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.PENTACLES, ID.BuffType.QUEEN))
	displays["queen"].set_suit_and_type(DataStructures.SuitType.PENTACLES, ID.BuffType.QUEEN)
	displays["blocked"] = create_new_icon(ResourceAutoload.get_buff_icon(DataStructures.SuitType.PENTACLES, ID.BuffType.KING))
	displays["blocked"].set_suit_and_type(DataStructures.SuitType.PENTACLES, ID.BuffType.KING)

func update_display(dictionary: Dictionary):
	"""
	--- Dictionary Values ---
	"value" = current_pentacles
	"uses" = charges
	"queen_uses" = queen_charges
	"queen_inverted" = queen_inverted
	"blocked" = blocked
	"""

	set_display(displays["basic"],
				dictionary["value"] > 0,
				dictionary["value"]
			)
	set_display(displays["uses"],
				dictionary["uses"] > 0,
				dictionary["uses"],
	)
	set_display(displays["queen"],
				dictionary["queen_uses"] > 0,
				dictionary["queen_uses"],
				get_panel_color(!dictionary["queen_inverted"])
	)
	set_display(displays["blocked"],
				dictionary["blocked"],
				0,
				get_panel_color(false)
	)

