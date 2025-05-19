extends Button


@export var main: Main
# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(give_money)

func give_money():
	main.cv_manager._update_currency(1000)