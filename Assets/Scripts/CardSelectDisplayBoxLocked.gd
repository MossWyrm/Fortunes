extends Control
class_name CardSelectDisplayBoxLocked

@onready var card_face: TextureRect = $CardFace
@onready var card_overlay: TextureRect = $CardFace/CardOverlay
@onready var unlock_button: Button = $UnlockButton
@onready var title: Label = $UnlockButton/MarginContainer/VBoxContainer/CardTitle
@onready var cost: Label = $UnlockButton/MarginContainer/VBoxContainer/CardCost
@onready var slider: ColorRect = $UnlockButton/MASK/Bar
@onready var slider_mask: Panel = $UnlockButton/MASK


func display(card: Card) -> void:
	var texture = ResourceAutoload.get_card_texture(card)
	card_face.texture = texture["background"]
	card_overlay.texture = texture["overlay"]
	cost.text = ("Unlock: "+Tools.get_shorthand(card.unlock_cost) if !card.blocked else "Unavailable")
	title.text = card.card_title
	unlock_button.disabled = card.blocked || (Stats.clairvoyance < card.unlock_cost)
	
	
func set_slider_percent(percent: float) -> void:
	slider.scale.x = percent

	