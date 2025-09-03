extends Node
class_name BuffManager

## Base class for managing buff displays

var displays: Dictionary[String, buff_display]
var major_displays: Dictionary[int, buff_display]
var buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display.tscn")
var major_buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display_major.tscn")
var _initialization_complete: bool = false


func update_display(_dictionary: Dictionary) -> void:
	if not _initialization_complete:
		DebugManager.print_ui_displays("Buff Icons not initialized yet, skipping update")
		return
	# Override this method in subclasses for actual display logic
	pass

## Call this at the end of _init_icons() in subclasses
func _mark_initialization_complete():
	_initialization_complete = true


## For regular suits: type_or_id is the BuffType [br]
## For MAJOR suit: type_or_id is the Major card ID
func create_icon(suit, type_or_id):
	var is_major = suit == DataStructures.SuitType.MAJOR
	var tooltip_card = Tools.get_buff_card(suit, type_or_id)
	var icon_texture = PreloadedResources.get_buff_icon(suit, type_or_id)
	var result = await _create_new_icon(
		icon_texture,
		is_major,
		tooltip_card
	)
	return result

func _create_new_icon(texture: Texture2D, major: bool = false, tooltip_card: Card = null):
	var display
	if major:
		display = major_buff_scene.instantiate()
	else:
		display = buff_scene.instantiate()
	add_child(display)
	await display.initialization_complete
	display.set_texture(texture)
	display.set_text("")
	display.set_panel_color(Color.WHITE)
	if tooltip_card != null:
			display.set_tooltip_card(tooltip_card)
	display.name = Tools.get_card_title(tooltip_card)
	return display

## Sets the display state for a buff_display or major_display_box icon.
func set_display(buff, visible: bool, charges: float = 0, color: Color = Color.WHITE, is_positive: bool = true, texture: Texture2D = null) -> void:
	if buff is buff_display:
		if !visible && buff.is_visible():
			await buff.hide_anim()
		else:
			buff.modulate = Color.WHITE
		buff.visible = visible
		var string_to_show: String
		if float(int(charges)) == charges:
			string_to_show = str(int(charges))
		else:
			string_to_show = "%0.2f" % [charges]
		buff.set_text(string_to_show if charges != 0 else "")
		buff.set_panel_color(color)
	elif buff.has_method("set_value") and buff.has_method("set_panel_color"):
		buff.visible = visible
		buff.set_value(int(charges))
		buff.set_panel_color(is_positive)
		if texture != null and buff.has_method("update_texture"):
			buff.update_texture(texture)

func get_panel_color(good: bool) -> Color:
	return DataStructures.core_color.GOOD if good else DataStructures.core_color.BAD