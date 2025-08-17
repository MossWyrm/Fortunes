
extends Node
class_name BuffManager

# === Variables ===
var displays: Dictionary[String, buff_display]
var major_displays: Dictionary[int, major_buff_display] # Can store buff_display or major_display_box
var buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display.tscn")
var major_buff_scene: PackedScene = preload("res://Assets/Scenes/buff_display_major.tscn")

# === Core Methods ===

## Override this in subclasses to update the display for a given dictionary of state.
func update_display(_dictionary: Dictionary) -> void:
	pass


## Creates a buff_display icon with all standard parameters.
## [suit]      Suit type (int).
## [buff_type] Buff type (int).
## Returns a new buff_display node with tooltip and suit/type set.
## Creates the correct display node for the given suit and buff_type/major_id.
func create_icon(suit, buff_type):
	var is_major = suit == DataStructures.SuitType.MAJOR
	return _create_new_icon(
		ResourceAutoload.get_buff_icon(suit, buff_type),
		is_major,
		Tools.create_buff_tooltip(suit, buff_type),
		suit,
		buff_type
	)



## Creates a new buff_display icon, optionally setting tooltip data and suit/type for DRY usage.
## [texture]      Icon texture.
## [major]        If true, use the major_buff_scene.
## [tooltip_data] (Optional) TooltipData to attach to the icon.
## [suit]         (Optional) SuitType to set on the icon.
## [buff_type]    (Optional) BuffType to set on the icon.
## Returns a new buff_display node, ready for use in the UI.
func _create_new_icon(texture: Texture2D, major: bool = false, tooltip_data: TooltipData = null, suit = null, buff_type = null):
	var display
	if major:
		display = major_buff_scene.instantiate()
		display.update_texture(texture)
		display.set_value(0)
		display.set_panel_color(true)
	else:
		display = buff_scene.instantiate()
		display.init()
		display.set_texture(texture)
		display.set_text("")
		display.set_panel_color(Color.WHITE)
		if tooltip_data != null:
			display.set_tooltip_data(tooltip_data)
		if suit != null and buff_type != null:
			display.set_suit_and_type(suit, buff_type)
	add_child(display)
	return display


## Sets the display state for a buff_display or major_display_box icon.
## [buff]     buff_display or major_display_box instance.
## [visible]  Whether the icon should be visible.
## [charges]  (Optional) Number to display.
## [color]    (Optional) Panel color.
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
		buff.set_text(string_to_show if charges > 0 else "")
		buff.set_panel_color(color)
	elif buff.has_method("set_value") and buff.has_method("set_panel_color"):
		buff.visible = visible
		buff.set_value(int(charges))
		buff.set_panel_color(is_positive)
		if texture != null and buff.has_method("update_texture"):
			buff.update_texture(texture)

## Returns a color for the panel based on good/bad state.
## [good] If true, returns GOOD color; else BAD color.
func get_panel_color(good: bool) -> Color:
	return DataStructures.core_color.GOOD if good else DataStructures.core_color.BAD