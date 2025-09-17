extends HBoxContainer

var count = 0
var timer: Timer = Timer.new()

func _ready():
	gui_input.connect(_on_gui_input)
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func _on_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		timer.wait_time = 1.0
		count += 1


func _process(_delta):
	if count > 0:
		timer.start()
	if count >= 5:
		count = 0
		timer.stop()
		EventBus.emit_request_debug_menu()

func _on_timer_timeout() -> void:
	count = 0
	timer.stop()