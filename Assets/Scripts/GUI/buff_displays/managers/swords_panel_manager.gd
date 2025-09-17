extends BuffManager


func _ready():
	await _init_icons()

func _init_icons():
	var suit = DataStructures.SuitType.SWORDS
	if not displays.has("basic"):
		displays["basic"] = await create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("page_positive"):
		displays["page_positive"] = await create_icon(suit, DataStructures.BuffType.PAGE)
	if not displays.has("page_negative"):
		displays["page_negative"] = await create_icon(suit, DataStructures.BuffType.PAGE)
	if not displays.has("queen"):
		displays["queen"] = await create_icon(suit, DataStructures.BuffType.QUEEN)
	if not displays.has("king_positive"):
		displays["king_positive"] = await create_icon(suit, DataStructures.BuffType.KING)
	if not displays.has("king_negative"):
		displays["king_negative"] = await create_icon(suit, DataStructures.BuffType.KING)
	_mark_initialization_complete()

func update_display(dictionary: Dictionary) -> void:
	"""
	Expects a dictionary of the form:
	{
		"combo": <combo>,
		"combo_value": <combo_value>,
		"page_positive_charges": <page_pos_charges>,
		"page_negative_charges": <page_neg_charges>,
		"king_protection": <king_protection>,
		"king_destruction": <king_destruction>
	}
	- Displays a buff icon for current combo ("basic").
	- Displays a buff icon for positive/negative page charges ("page_positive", "page_negative").
	- Displays a buff icon for king protection/destruction ("king_positive", "king_negative").
	"""
	if not _initialization_complete:
		return
	set_display(displays["basic"], dictionary.get("combo", 0) > 0, dictionary.get("combo", 0))
	set_display(displays["page_positive"], dictionary.get("page_positive_charges", 0) > 0, dictionary.get("page_positive_charges", 0), get_panel_color(true))
	set_display(displays["page_negative"], dictionary.get("page_negative_charges", 0) > 0, dictionary.get("page_negative_charges", 0), get_panel_color(false))
	set_display(displays["queen"], dictionary.get("combo_value", 0) != 1, abs(dictionary.get("combo_value", 0)), get_panel_color(dictionary.get("combo_value", 0) > 1))
	set_display(displays["king_positive"], dictionary.get("king_protection", 0) > 0, dictionary.get("king_protection", 0), get_panel_color(true))
	set_display(displays["king_negative"], dictionary.get("king_destruction", 0) > 0, dictionary.get("king_destruction", 0), get_panel_color(false))
