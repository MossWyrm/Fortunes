extends Node

var control_main: Control 
var simultaneous_scene
var fade_in: bool = false
var fade_out: bool = false
var timer: float = 0

var fade_in_time: float = 2.0
var fade_out_time: float = 2.0

signal fade_complete

func _ready() -> void:
	control_main = $Control
	timer = 0
	fade_in = true
	await fade_complete
	simultaneous_scene = preload("res://Assets/Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(simultaneous_scene)
	await get_tree().create_timer(2).timeout
	timer = 0
	fade_out = true
	await fade_complete
	queue_free()
	
func _process(delta: float) -> void:
	if fade_in:
		timer += delta
		_fade_in(timer/fade_in_time)
		if timer >= fade_in_time:
			fade_complete.emit()
			fade_in = false
	if fade_out:
		timer += delta
		_fade_out(timer/fade_out_time)
		if timer >= fade_out_time:
			fade_complete.emit()
			fade_out = false
		
func _fade_in(percent: float) -> void:
	control_main.modulate = Color.BLACK.lerp(Color.WHITE, percent)


func _fade_out(percent: float) -> void:
	var target_color: Color = Color.WHITE
	target_color.a = 0
	control_main.modulate = Color.WHITE.lerp(target_color,percent)
	
	