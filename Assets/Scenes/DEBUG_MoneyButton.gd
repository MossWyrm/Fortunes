extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(give_money)

func give_money():
	Events.emit_update_currency_display(1000)