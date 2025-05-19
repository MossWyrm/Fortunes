extends "res://Assets/Scripts/GUI/currency_display.gd"


func _update_text(value):
	self.text = str("%d" % value)