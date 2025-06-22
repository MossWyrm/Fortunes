extends Button

func _ready() -> void:
	pressed.connect(reset_game)
	
func reset_game() -> void:
	Events.emit_reset_game()