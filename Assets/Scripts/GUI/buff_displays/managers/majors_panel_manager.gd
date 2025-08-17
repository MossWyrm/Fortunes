extends BuffManager

var init_dict: Dictionary = {}

func _ready() -> void:
	GameManager.event_bus.suit_display_updated.connect(_on_suit_display_updated)
	_init_icons()
	if init_dict.size() > 0:
		update_display(init_dict)

func _init_icons():
	var suit = DataStructures.SuitType.MAJOR
	for value in DataStructures.MAJOR_ID.values():
		if not major_displays.has(value):
			major_displays[value] = create_icon(suit, value)

func _on_suit_display_updated(suit, display_data):
	if suit == DataStructures.SuitType.MAJOR:
		update_display(display_data)

func update_display(dictionary: Dictionary) -> void:
	if major_displays.size() <= 0:
		init_dict = dictionary
		return
	"""
	Expects a dictionary of the form:
	{
		<major_id>: [<state: DataStructures.CardState>, <value: int>, ...],
		...
	}
	- Displays a buff icon for each major arcana, using its unique ID.
	- The state determines icon color and visibility.
	- The value is shown as the icon's label/amount.
	"""
	for key in dictionary.keys():
		var arr = dictionary[key]
		var state = arr[0]
		var value = 0
		if arr.size() > 1:
			value = arr[1]
		var is_positive = state == DataStructures.CardState.POSITIVE
		set_display(
			major_displays[key],
			state != DataStructures.CardState.INACTIVE,
			value,
			Color.WHITE, # Not used by major_display_box
			is_positive
		)
