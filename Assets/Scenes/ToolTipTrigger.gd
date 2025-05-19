extends Panel


var mouse_within: bool = false
var mouse_left_down: bool = false
var time = 0
@export var tooltip_event: BaseTooltip

func _on_mouse_entered():
	mouse_within = true

func _on_mouse_exited():
	mouse_within = false


func _on_gui_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false

func _process(delta):
	if mouse_within and mouse_left_down:
		time += delta
		if time >= 1.5:
			Events.emit_tooltip(tooltip_event)
			print("Tooltip Spawned")
			time = 0
	else:
		time = 0