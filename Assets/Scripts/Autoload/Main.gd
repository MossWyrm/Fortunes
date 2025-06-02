extends Node


var deck_manager: Node:
	set(value):
		deck_manager = value
	get:
		while deck_manager == null:
			await get_tree().process_frame
		return deck_manager

var cv_manager: Node:
	set(value):
		cv_manager = value
	get:
		while cv_manager == null:
			await get_tree().process_frame
		return cv_manager