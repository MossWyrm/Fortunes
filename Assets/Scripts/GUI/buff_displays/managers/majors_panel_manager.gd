extends BuffManager

var init_dict: Dictionary = {}

func _ready() -> void:
	for value in ID.MajorID.values():
		major_displays[value] = create_new_icon(ResourceAutoload.get_numeral(500+value), true)
		major_displays[value].set_suit_and_type(ID.Suits.MAJOR,ID.BuffType.GENERAL,value)
	if init_dict.size() >= 0: update_display(init_dict)
	
func update_display(dictionary: Dictionary) -> void:
	if major_displays.size() <=0:
		init_dict = dictionary
		return
	"""
	Dictionary Structure:
	ID.MajorID = [ID.CardState, relevant value (bool, int etc)]
	"""
	for key in dictionary.keys():
		var output_color: Color = (
			  Color.WHITE 	if (dictionary[key][0] != ID.CardState.POSITIVE 
								&& dictionary[key][0] != ID.CardState.NEGATIVE) 
							else get_panel_color(dictionary[key][0] == ID.CardState.POSITIVE)
								  )
		set_display(major_displays[key],
					dictionary[key][0] != ID.CardState.INACTIVE,
					0 if dictionary[key].size() < 2 else dictionary[key][1],
					output_color
					)
