extends Control
class_name CurrencyDisplay

@export var currency_text: Label
	
func update_text(value):
	currency_text.text = Tools.get_shorthand(value)

