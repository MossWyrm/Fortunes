extends MenuBar

## Debug Menu key access

var just_toggled = false
func _ready():
	EventBus.request_debug_menu.connect(_on_request_debug_menu)

func _process(_delta):
	var key1 = Input.is_action_pressed("debug_menu_1")
	var key2 = Input.is_action_pressed("debug_menu_2")

	if key1 and key2 and not just_toggled:
		toggle_menu()
	elif not key1 and not key2:
		just_toggled = false

func toggle_menu():
	visible = not visible
	just_toggled = true

func _on_request_debug_menu():
	toggle_menu()