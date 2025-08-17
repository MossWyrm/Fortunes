extends BuffManager


func _ready():
	GameManager.event_bus.suit_display_updated.connect(_on_suit_display_updated)
	_init_icons()

func _init_icons():
	var suit = DataStructures.SuitType.CUPS
	if not displays.has("page"):
		displays["page"] = create_icon(suit, DataStructures.BuffType.PAGE)
	# Cup icons are created dynamically in update_display

func _on_suit_display_updated(suit, display_data):
	if suit == DataStructures.SuitType.CUPS:
		update_display(display_data)

func update_display(dictionary: Dictionary) -> void:
	"""
	Expects a dictionary of the form:
	{
		"cups": { 0: <cup_value>, 1: <cup_value>, ... },
		"page_size_mod": <page_size_mod_value>
	}
	- Displays a buff icon for each cup in the cups dictionary.
	- Hides unused cup icons if the number of cups decreases.
	- Shows a PAGE icon if page_size_mod is present and nonzero, with its value.
	"""
	var cups = dictionary.get("cups", {})
	var cup_keys = cups.keys()
	var num_cups = cup_keys.size()

	# Hide any extra displays
	for key in displays.keys():
		if key.begins_with("cup_"):
			var idx = int(key.substr(4))
			if idx >= num_cups:
				displays[key].hide()

	# Show or create displays for each cup
	for idx in cup_keys:
		var key = "cup_%s" % [str(idx)]
		if not displays.has(key):
			displays[key] = create_icon(DataStructures.SuitType.CUPS, DataStructures.BuffType.BASIC)
		set_display(displays[key], cups[idx] != 0, cups[idx])

	# Show a page icon if a page modifier is present and nonzero
	if dictionary.has("page_size_mod") and dictionary["page_size_mod"] != 0:
		set_display(
			displays["page"],
			true,
			dictionary["page_size_mod"],
			get_panel_color(dictionary["page_size_mod"] > 0)
		)
	elif displays.has("page"):
		displays["page"].hide()