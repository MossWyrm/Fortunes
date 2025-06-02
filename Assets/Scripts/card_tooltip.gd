extends Control
class_name CardTooltip

@onready var locked_overlay: Control = $CardInfo/Details/MarginContainer/HBoxContainer/Panel/CardFace/MASK
@onready var card_face: TextureRect = $CardInfo/Details/MarginContainer/HBoxContainer/Panel/CardFace
@onready var card_overlay: TextureRect = $CardInfo/Details/MarginContainer/HBoxContainer/Panel/CardFace/CardOverlay
@onready var card_title: RichTextLabel = $CardInfo/Details/MarginContainer/HBoxContainer/VBoxContainer/CardTitle
@onready var card_desc: RichTextLabel = $CardInfo/Details/MarginContainer/HBoxContainer/VBoxContainer/CardDesc
@onready var numeral: TextureRect = $CardInfo/Details/MarginContainer/HBoxContainer/Panel/CardFace/Numeral

func _ready() -> void:
	Events.card_tooltip.connect(display)
	
func display(card:Card) -> void:
	var texture = ResourceAutoload.get_card_texture(card)
	card_face.texture = texture["background"]
	card_overlay.texture = texture["overlay"]
	if texture["numeral"] != null:
		numeral.texture = texture["numeral"]
		numeral.show()
	else:
		numeral.hide()
	
	locked_overlay.visible = !card.unlocked
	card_title.text = card.card_title
	card_title.add_theme_color_override("default_color",ID.SuitColor[str(ResourceIDs.Suits.keys()[card.card_suit])])
	card_desc.text = Descriptions.get_description(card,true)
	show()