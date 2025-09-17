extends BuffManager


func _ready():
	await _init_icons()

func _init_icons():
	var suit = DataStructures.SuitType.WANDS
	if not displays.has("basic"):
		displays["basic"] = await create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("page"):
		displays["page"] = await create_icon(suit, DataStructures.BuffType.PAGE)
	if not displays.has("knight"):
		displays["knight"] = await create_icon(suit, DataStructures.BuffType.KNIGHT)
	if not displays.has("queen"):
		displays["queen"] = await create_icon(suit, DataStructures.BuffType.QUEEN)
	_mark_initialization_complete() 

func update_display(dictionary: Dictionary) -> void:
	"""
	Expects a dictionary of the form:
	{
		"value": <wand_multiplier>,
		"value_buff": <queen_mod>,
		"page_charges": <page_charges>,
		"page_positive": <page_positive>,
		"knight_charges": <knight_charges>,
		"knight_positive": <knight_positive>
	}
	- Displays a buff icon for current wand multiplier ("basic").
	- Displays a buff icon for page charges ("page"), with color indicating positivity.
	- Displays a buff icon for knight charges ("knight"), with color indicating positivity.
	"""
	if not _initialization_complete:
		return
	set_display(displays["basic"], dictionary.get("value", 0.0) > 0.0, dictionary.get("value", 0.0))
	set_display(displays["page"], dictionary.get("page_charges", 0) > 0, dictionary.get("page_charges", 0), get_panel_color(dictionary.get("page_positive", false)))
	set_display(displays["knight"], dictionary.get("knight_charges", 0) > 0, dictionary.get("knight_charges", 0), get_panel_color(dictionary.get("knight_positive", false)))
	set_display(displays["queen"], dictionary.get("value_buff", 0) != 0, abs(dictionary.get("value_buff", 0)), get_panel_color(dictionary.get("value_buff", 0) > 0))