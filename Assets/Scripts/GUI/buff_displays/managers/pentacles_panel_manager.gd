extends BuffManager


func _ready():
	GameManager.event_bus.suit_display_updated.connect(_on_suit_display_updated)
	_init_icons()

func _init_icons():
	var suit = DataStructures.SuitType.PENTACLES
	if not displays.has("basic"):
		displays["basic"] = create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("uses"):
		displays["uses"] = create_icon(suit, DataStructures.BuffType.BASIC)
	if not displays.has("queen"):
		displays["queen"] = create_icon(suit, DataStructures.BuffType.QUEEN)
	if not displays.has("blocked"):
		displays["blocked"] = create_icon(suit, DataStructures.BuffType.KING)

func _on_suit_display_updated(suit, display_data):
	if suit == DataStructures.SuitType.PENTACLES:
		update_display(display_data)

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
	var value = dictionary.get("value", 0)
	var uses = dictionary.get("uses", 0)
	var queen_uses = dictionary.get("queen_uses", 0)
	var queen_inverted = dictionary.get("queen_inverted", false)
	var blocked = dictionary.get("blocked", false)

	set_display(displays["basic"], value > 0, value)
	set_display(displays["uses"], uses > 0, uses)
	set_display(displays["queen"], queen_uses > 0, queen_uses, get_panel_color(!queen_inverted))
	set_display(displays["blocked"], blocked, 0, get_panel_color(false))

