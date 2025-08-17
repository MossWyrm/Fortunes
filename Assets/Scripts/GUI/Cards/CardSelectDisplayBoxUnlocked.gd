extends Control
class_name CardSelectDisplayBoxUnlocked
## Unlocked card display box for deck creator
##
## Shows unlocked cards that can be added to or removed from the deck.
## Provides interactive buttons and hover effects for deck modification.

#region Node References
@onready var card_image: TextureRect = $Panel/CardFace
@onready var card_overlay: TextureRect = $Panel/CardFace/CardOverlay
@onready var card_title: Label = $ButtonsAndText/CardName
@onready var current_count_display: Label = $ButtonsAndText/DeckModButtons/CurrentCardCount
@onready var add_card_button: TextureButton = $ButtonsAndText/DeckModButtons/AddToDeck
@onready var remove_card_button: TextureButton = $ButtonsAndText/DeckModButtons/RemoveFromDeck
#endregion

#region Constants
const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)
const NORMAL_SCALE: Vector2 = Vector2.ONE
#endregion

#region Display Management
# Display unlocked card information and deck status
func display(card: Card, currently_in_deck: int = -1) -> void:
	if not card:
		push_error("CardSelectDisplayBoxUnlocked: Cannot display null card")
		return
	
	_setup_card_visuals(card)
	_setup_card_information(card, currently_in_deck)
	_reset_hover_state()

# Setup card visual elements
func _setup_card_visuals(card: Card) -> void:
	var texture = PreloadedResources.get_card_texture(card)
	
	if card_image:
		card_image.texture = texture["background"]
	
	if card_overlay:
		card_overlay.texture = texture["overlay"]

# Setup card title and deck count information
func _setup_card_information(card: Card, currently_in_deck: int) -> void:
	if card_title:
		card_title.text = card.card_title
	
	if current_count_display:
		current_count_display.text = str(currently_in_deck)

# Reset hover state to normal
func _reset_hover_state() -> void:
	hover_end()
#endregion

#region Button State Management
# Control add button availability
func stop_add(stop: bool) -> void:
	if add_card_button:
		add_card_button.disabled = stop

# Control remove button availability
func stop_remove(stop: bool) -> void:
	if remove_card_button:
		remove_card_button.disabled = stop
#endregion

#region Hover Effects
# Start hover effect - scale up card image
func hover_start() -> void:
	if card_image:
		card_image.scale = HOVER_SCALE

# End hover effect - return card image to normal scale
func hover_end() -> void:
	if card_image:
		card_image.scale = NORMAL_SCALE
#endregion