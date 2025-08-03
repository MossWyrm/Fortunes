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
	GameManager.event_bus.tooltip_requested.connect(display)
	
func display(tooltip:DataStructures.TooltipData) -> void:
	var texture = ResourceAutoload.get_card_texture(tooltip.card)
	card_face.texture = texture["background"]
	card_overlay.texture = texture["overlay"]
	if texture["numeral"] != null:
		numeral.texture = texture["numeral"]
		numeral.show()
	else:
		numeral.hide()
	
	locked_overlay.visible = !tooltip.card.unlocked
	card_title.text = tooltip.card.card_title
	card_title.add_theme_color_override("default_color",ID.SuitColor[str(DataStructures.SuitType.keys()[card.card_suit])])
	var description: Dictionary = CardDescriptions.get_description(card,true)
	card_desc.text = description["card"]
	suit_desc.text = description["suit"]
	show()
	
# func display_for_buff(suit: DataStructures.SuitType, type: ID.BuffType, card_number: int) -> void:
# 	var card_id_num: int = 500 + card_number if suit == DataStructures.SuitType.MAJOR else ((suit+1)*100)+10+type
# 	display(GameManager.game_state.deck_manager.get_card(card_id_num))
