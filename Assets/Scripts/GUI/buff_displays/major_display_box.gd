extends TextureRect
class_name major_buff_display

# === Nodes & State ===
@onready var label: Label = $Charges
@onready var highlight: ColorRect = $Mask/ColorRect

var _remaining_charges: int = 0

# === UI Update Methods ===
func update_texture(card_texture: Texture2D) -> void:
	if card_texture != null and texture != card_texture:
		texture = card_texture

func set_value(value: int) -> void:
	_remaining_charges = value
	_update_text()

func set_panel_color(is_positive: bool = true) -> void:
	# Uses DataStructures.core_color for consistency with other managers
	highlight.color = DataStructures.core_color.GOOD if is_positive else DataStructures.core_color.BAD
	highlight.show()

func _update_text() -> void:
	label.visible = _remaining_charges > 0
	label.text = str(_remaining_charges)
