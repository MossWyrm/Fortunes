extends Control
class_name deck_creator_navigator

@export var cups_panel : ScrollContainer
@export var wands_panel : ScrollContainer
@export var pentacles_panel : ScrollContainer
@export var swords_panel : ScrollContainer
@export var majors_panel : ScrollContainer
var panels = []
@export var buttons: Array[DeckSelectNavButton] = []

func _ready():
	set_panels()

func set_panels():
	panels.append(cups_panel)
	panels.append(wands_panel)
	panels.append(pentacles_panel)
	panels.append(swords_panel)
	panels.append(majors_panel)


func open_panel(texture_button: TextureButton, number: int):
	for i in panels.size():
		panels[i].visible = true if i == number else false
		panels[i].scroll_vertical = 0	
	for button in buttons:
		if button == texture_button:
			button.select()
		else:
			button.deselect()
