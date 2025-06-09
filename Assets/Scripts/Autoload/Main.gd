extends Node


var deck_manager: Deck_Manager:
	set(value):
		deck_manager = value
	get:
		while deck_manager == null:
			await get_tree().process_frame
		return deck_manager

var cv_manager: CVC:
	set(value):
		cv_manager = value
	get:
		while cv_manager == null:
			await get_tree().process_frame
		return cv_manager