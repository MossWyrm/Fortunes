extends Node
class_name BuffManager

var displays: Dictionary[String, buff_display]
var major_displays: Dictionary[int, buff_display]
var buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display.tscn")
var major_buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display_major.tscn")

func update_display(_dictionary: Dictionary) -> void:
	pass
	
func create_new_icon(texture: Texture2D, major: bool = false) -> buff_display:
	var display: buff_display = buff_scene.instantiate() if !major else major_buff_scene.instantiate()
	display.init()
	display.set_texture(texture)
	display.set_text("")
	display.set_panel_color(Color.WHITE)
	add_child(display)
	return display
	
func set_display(buff: buff_display, visible: bool, charges: float = 0, color: Color = Color.WHITE) -> void:
	if !visible && buff.is_visible():
		await buff.hide_anim()
	else:
		buff.modulate = Color.WHITE
	buff.visible = visible
	var string_to_show: String   
	if float(int(charges)) == charges:
		string_to_show = str(int(charges))
	else:
		string_to_show = "%0.2f"%[charges]
	buff.set_text(string_to_show if charges > 0 else "")
	buff.set_panel_color(color)
	
func get_panel_color(good: bool) -> Color:
	return ID.PanelColor["GOOD"] if good else ID.PanelColor["BAD"]