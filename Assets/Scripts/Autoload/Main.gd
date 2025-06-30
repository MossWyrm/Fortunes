extends Node

var signal_sent: = false
signal references_ready

var deck_manager: Deck_Manager:
	set(value):
		deck_manager = value
	get:
#		while deck_manager == null:
#			await get_tree().process_frame
		return deck_manager

var cv_manager: CVC:
	set(value):
		cv_manager = value
	get:
#		while cv_manager == null:
#			await get_tree().process_frame
		return cv_manager

var upgrade_manager: UpgradesController:
	set(value):
		upgrade_manager = value
	get:
#		while upgrade_manager == null:
#			await get_tree().process_frame
		return upgrade_manager
		
var save_manager: SaveManager:
	set(value):
		save_manager = value
	get:
#		while save_manager == null:
#			await get_tree().process_frame
		return save_manager
 
var audio_manager: AudioManager:
	set(value):
		audio_manager = value
	get:
#		while audio_manager == null:
#			await get_tree().process_frame
		return audio_manager
		
func _process(_delta: float) -> void:
	if !signal_sent && deck_manager != null && cv_manager != null && upgrade_manager != null && save_manager != null && audio_manager != null:
		references_ready.emit()
		signal_sent = true 