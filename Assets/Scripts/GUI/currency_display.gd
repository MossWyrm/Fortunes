extends Control
class_name CurrencyDisplay

@export var currency_text: Label

func _ready():
	GameManager.event_bus.currency_updated.connect(update_text)
	
	# Initial update
	update_text(0)  # Default to 0, will be updated by events

func _on_currency_updated(amount: int, _currency_type: DataStructures.CurrencyType):
	# Handle new architecture currency updates
	# For now, just update the display with the amount
	update_text(amount)
	
func update_text(value):
	currency_text.text = Tools.get_shorthand(value)

