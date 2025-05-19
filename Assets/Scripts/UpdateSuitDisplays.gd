extends Node

@export var cup_display : Node
@export var wand_display : Node
@export var pentacles_display : Node
@export var swords_display : Node


func _ready():
	Events.update_suit_displays.connect(update_suit_displays)
	update_suit_displays()


func update_suit_displays():
	cup_display._update_cup_display()
	wand_display._update_wand_display()
	pentacles_display._update_pentacles_display()
	swords_display._update_swords_display()



