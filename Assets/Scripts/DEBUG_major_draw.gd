extends Button

# Called when the node enters the scene tree for the first time.
func _ready():
	pressed.connect(draw_major)

func draw_major():
	GM.deck_manager.debug_draw_major()