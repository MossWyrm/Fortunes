extends Control
class_name CardSelectDisplayBoxUnlocked

@onready var card_image: TextureRect = $Panel/CardFace
@onready var card_overlay: TextureRect = $Panel/CardFace/CardOverlay

@onready var card_title: Label = $ButtonsAndText/CardName
@onready var current_count_display: Label = $ButtonsAndText/DeckModButtons/CurrentCardCount
@onready var add_card_button: TextureButton = $ButtonsAndText/DeckModButtons/AddToDeck
@onready var remove_card_button: TextureButton = $ButtonsAndText/DeckModButtons/RemoveFromDeck

func display(card: DataStructures.Card, currently_in_deck: int = -1) -> void:
	var texture = ResourceAutoload.get_card_texture(card)
	card_image.texture = texture["background"]
	card_overlay.texture = texture["overlay"]
	current_count_display.text = str(currently_in_deck)
	card_title.text = card.card_title
	hover_end()

func stop_add(stop: bool) -> void:
	add_card_button.disabled = stop
	
func stop_remove(stop: bool) -> void:
	remove_card_button.disabled = stop
	
func hover_start() -> void:
	card_image.scale = Vector2(1.1,1.1)
	
func hover_end() -> void:
	card_image.scale = Vector2.ONE