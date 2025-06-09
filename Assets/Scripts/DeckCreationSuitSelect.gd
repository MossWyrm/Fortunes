extends Control
class_name deck_creator_navigator

@export var cups_panel : ScrollContainer
@export var wands_panel : ScrollContainer
@export var pentacles_panel : ScrollContainer
@export var swords_panel : ScrollContainer
@export var majors_panel : ScrollContainer
var panels = []

func _ready():
	set_panels()

func set_panels():
	panels.append(cups_panel)
	panels.append(wands_panel)
	panels.append(pentacles_panel)
	panels.append(swords_panel)
	panels.append(majors_panel)


func open_panel(number: int):
	for i in panels.size():
		panels[i].visible = true if i == number else false
		panels[i].scroll_vertical = 0	
