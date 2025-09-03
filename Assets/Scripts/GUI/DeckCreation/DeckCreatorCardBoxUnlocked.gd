extends Control
class_name DeckCreatorCardBoxUnlocked

## Card selection display box for unlocked cards
## Handles display and interaction for adding/removing cards from deck

@onready var card_image: TextureRect = $Panel/CardFace
@onready var card_overlay: TextureRect = $Panel/CardFace/CardOverlay
@onready var card_title: Label = $ButtonsAndText/CardName
@onready var current_count_display: Label = $ButtonsAndText/DeckModButtons/CurrentCardCount
@onready var add_card_button: TextureButton = $ButtonsAndText/DeckModButtons/AddToDeck
@onready var remove_card_button: TextureButton = $ButtonsAndText/DeckModButtons/RemoveFromDeck

const HOVER_SCALE: Vector2 = Vector2(1.1, 1.1)
const NORMAL_SCALE: Vector2 = Vector2.ONE

var deck_creator: DeckCreator
var stored_card_id: int

func _ready():
	add_card_button.pressed.connect(_on_add_card_pressed)
	remove_card_button.pressed.connect(_on_remove_card_pressed)

#region Display Management
func update(data: DeckCreatorDisplayData, creator: DeckCreator) -> void:
	if not data:
		DebugManager.print_deck_operations("DeckCreatorCardBoxUnlocked: Cannot update with null data")
		return
	if not deck_creator:
		deck_creator = creator

	stored_card_id = data.card_id
	card_title.text = data.display_title
	current_count_display.text = str(data.amount_in_deck)
	add_card_button.disabled = not data.is_card_addable
	remove_card_button.disabled = not data.is_card_removable
	card_image.texture = data.card_background
	card_overlay.texture = data.card_overlay

	_reset_hover_state()
#endregion

#region Button Interactions
func _on_add_card_pressed() -> void:
	deck_creator.add_card_to_deck(stored_card_id)

func _on_remove_card_pressed() -> void:
	deck_creator.remove_card_from_deck(stored_card_id)

# Handle card face input for tooltips
func _on_card_face_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("ui_click"):
		deck_creator.show_card_tooltip(stored_card_id)
#endregion

#region Hover Effects
func _reset_hover_state() -> void:
	hover_end()

func hover_start() -> void:
	card_image.scale = HOVER_SCALE

func hover_end() -> void:
	card_image.scale = NORMAL_SCALE
#endregion