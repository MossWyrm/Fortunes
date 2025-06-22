extends Node

@export var cup_display : BuffManager
@export var wand_display : BuffManager
@export var pentacles_display : BuffManager
@export var swords_display : BuffManager
@export var majors_display: BuffManager


func _ready() -> void:
	Events.shuffle.connect(shuffle)
	Events.update_suit_displays.connect(update_suit_displays)
	update_suit_displays()


func update_suit_displays() -> void:
	cup_display.update_display(GM.cv_manager.get_display(ID.Suits.CUPS))
	wand_display.update_display(GM.cv_manager.get_display(ID.Suits.WANDS))
	pentacles_display.update_display(GM.cv_manager.get_display(ID.Suits.PENTACLES))
	swords_display.update_display(GM.cv_manager.get_display(ID.Suits.SWORDS))
	majors_display.update_display(GM.cv_manager.get_display(ID.Suits.MAJOR))
	
func shuffle(_safely) -> void:
	await get_tree().process_frame
	update_suit_displays()