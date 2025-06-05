extends TextureRect

@onready var charges: Label = $Label
@onready var color_rect: ColorRect = $MASK/ColorRect

var remaining_charges: int

func update(card_texture: Texture2D, value: int, positive: bool) -> void:
	if texture != card_texture:
		texture = card_texture
	color_rect.color = ID.PanelColor["GOOD"] if positive else ID.PanelColor["BAD"]
	remaining_charges = value
	update_text()
	
func update_text() -> void:
	charges.visible = remaining_charges > 0
	charges.text = str(remaining_charges)
