extends Button

# Called when the node enters the scene tree for the first time.
@export var money_to_give: int = 1000

func _ready():
	pressed.connect(give_money)

func give_money():
	Events.emit_update_currency(money_to_give)