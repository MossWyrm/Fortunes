extends Node
class_name CurrencyManager

@export var currency_display: CurrencyDisplay
var _currency: int:
	get:
		return Stats.current_currency
	set(value):
		Stats.current_currency = value

func _ready() -> void:
	Events.update_currency_display.connect(update_currency)
	currency_display.update_text(_currency)


func update_currency(card_value) -> void:
	if _currency + card_value <= 0:
		Events.emit_floating_text(-_currency)
	else:
		Events.emit_floating_text(card_value)
	_currency += card_value
	if _currency < 0:
		_currency = 0
	currency_display.update_text(_currency)