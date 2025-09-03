extends Control
class_name CurrencyDisplay

## Currency display component

@export var currency_text: Label

func _ready():
	update_text(0)
	
func update_text(value):
	currency_text.text = Tools.get_shorthand(value)

