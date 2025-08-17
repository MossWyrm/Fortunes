extends Control
class_name CurrencyDisplay

@export var currency_text: Label

func _ready():
	update_text(0)  # Default to 0, will be updated by events
	
func update_text(value):
	currency_text.text = Tools.get_shorthand(value)

