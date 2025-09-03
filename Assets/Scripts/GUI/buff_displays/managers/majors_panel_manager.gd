extends BuffManager

var init_dict: Dictionary = {}

func _ready() -> void:
	await _init_icons()
	if init_dict.size() > 0:
		update_display(init_dict)

func _init_icons():
	var suit = DataStructures.SuitType.MAJOR
	for value in DataStructures.MAJOR_ID.values():
		if not major_displays.has(value):
			major_displays[value] = await create_icon(suit, value)
	_mark_initialization_complete()

func update_display(dictionary: Dictionary) -> void:
	if major_displays.size() <= 0:
		init_dict = dictionary
		return
	"""
	Expects a dictionary of the form:
	{
		<major_id>: {"card_state" : DataStructures.CardState, "value" : int},
		...
	}
	- Displays a buff icon for each major arcana, using its unique ID.
	- The state determines icon color and visibility.
	- The value is shown as the icon's label/amount.
	"""
	if not _initialization_complete:
		return
	for key in dictionary.keys():
		var state = dictionary[key]["card_state"]
		var value = dictionary[key]["value"]
		var is_positive = state == DataStructures.CardState.POSITIVE
		var panel_color = DataStructures.core_color.GOOD if is_positive else DataStructures.core_color.BAD
		set_display(
			major_displays[key],
			state != DataStructures.CardState.INACTIVE,
			value,
			panel_color, 
			is_positive
		)
		DebugManager.print_ui_displays("Updated major display for ID: %d. State: %s, Value: %d" % [key, state, value])
