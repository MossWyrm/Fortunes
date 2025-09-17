extends BuffManager


func _ready():
	await _init_icons()

func _init_icons():
	var suit = DataStructures.SuitType.PENTACLES
	if not displays.has("basic"):
		displays["basic"] = await create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("uses"):
		displays["uses"] = await create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("queen"):
		displays["queen"] = await create_icon(suit, DataStructures.BuffType.QUEEN)
	if not displays.has("blocked"):
		displays["blocked"] = await create_icon(suit, DataStructures.BuffType.KING)
	_mark_initialization_complete()

func update_display(dictionary: Dictionary) -> void:
	"""
	Expects a dictionary of the form:
	{
		"value": <current_pentacles>,
		"uses": <charges>,
		"queen_uses": <queen_charges>,
		"queen_inverted": <queen_inverted>,
		"blocked": <blocked>
	}
	- Displays a buff icon for current pentacles ("basic").
	- Displays a buff icon for pentacle uses ("uses").
	- Displays a buff icon for queen uses ("queen"), with color indicating inversion.
	- Displays a buff icon for blocked state ("blocked").
	"""
	if not _initialization_complete:
		return
	var value = dictionary.get("value", 0)
	var uses = dictionary.get("uses", 0)
	var queen_uses = dictionary.get("queen_uses", 0)
	var queen_inverted = dictionary.get("queen_inverted", false)
	var blocked = dictionary.get("blocked", false)

	set_display(displays["basic"], value > 0, value)
	set_display(displays["uses"], uses > 0, uses)
	set_display(displays["queen"], queen_uses > 0, queen_uses, get_panel_color(!queen_inverted))
	set_display(displays["blocked"], blocked, 0, get_panel_color(false))

