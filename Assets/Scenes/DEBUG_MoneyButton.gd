extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(give_money)

func give_money():
	GM.cv_manager._update_currency(1000)