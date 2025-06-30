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
	Events.buff_tooltip.connect(display_for_buff)
	
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
	card_title.add_theme_color_override("default_color",ID.SuitColor[str(ID.Suits.keys()[card.card_suit])])
	card_desc.text = Descriptions.get_description(card,true)
	show()
	
func display_for_buff(suit: ID.Suits, type: ID.BuffType, card_number: int) -> void:
	var card_id_num: int = 500 + card_number if suit == ID.Suits.MAJOR else ((suit+1)*100)+10+type
	display(GM.deck_manager.get_card(card_id_num))