extends Control
class_name CardTooltip

@onready var locked_overlay: Control = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/MASK
@onready var card_face: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace
@onready var card_overlay: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/CardOverlay
@onready var card_title: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardTitle
@onready var card_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardDesc
@onready var suit_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/SuitDesc
@onready var numeral: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/Numeral

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
	var description: Dictionary = Descriptions.get_description(card,true)
	card_desc.text = description["card"]
	suit_desc.text = description["suit"]
	show()
	
func display_for_buff(suit: ID.Suits, type: ID.BuffType, card_number: int) -> void:
	var card_id_num: int = 500 + card_number if suit == ID.Suits.MAJOR else ((suit+1)*100)+10+type
	display(GM.deck_manager.get_card(card_id_num))
