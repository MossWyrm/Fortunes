extends BuffManager

func update_display(dictionary: Dictionary) -> void:
	"""
	--- Dictionary Values ---
	1 = cup_value
	2 = cup_value
	...
	...
	
	"""
	if dictionary.size() < displays.size():
		var x: int = displays.size()
		while x > dictionary.size():
			displays["cup_%s"%[str(x-1)]].hide()
			x -= 1
	for z in dictionary.size():
		if(z+1 > displays.size()):
			var icon: buff_display = create_new_icon(ResourceAutoload.get_buff_icon(ID.Suits.CUPS, ID.BuffType.GENERAL))
			icon.set_suit_and_type(ID.Suits.CUPS, ID.BuffType.GENERAL)
			displays["cup_%s"%[str(z)]] = icon
		displays["cup_%s"%[str(z)]].show()
		displays["cup_%s"%[str(z)]].set_text(str(dictionary[z]) if dictionary[z] != 0 else "")
		z += 1