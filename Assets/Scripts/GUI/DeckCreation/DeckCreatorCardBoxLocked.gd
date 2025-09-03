extends Control
class_name DeckCreatorCardBoxLocked

## Card selection display box for locked cards
## Handles display and purchase interaction for locked cards

@onready var card_face: TextureRect = $CardFace
@onready var card_overlay: TextureRect = $CardFace/CardOverlay
@onready var unlock_button: Button = $UnlockButton
@onready var title: Label = $UnlockButton/MarginContainer/VBoxContainer/CardTitle
@onready var cost: Label = $UnlockButton/MarginContainer/VBoxContainer/CardCost
@onready var slider: ColorRect = $UnlockButton/MASK/Bar
@onready var slider_mask: Panel = $UnlockButton/MASK

var is_holding: bool = false
var hold_timer: float = 0.0
var hold_delay: float = GameConstants.HOLD_DELAY_DEFAULT

var deck_creator: DeckCreator
var stored_card_id: int

func _ready():
	unlock_button.gui_input.connect(_on_button_gui_input)

func update(data: DeckCreatorDisplayData, creator: DeckCreator) -> void:
	if not data:
		push_error("DeckCreatorCardBoxLocked: Cannot update with null data")
		return
	if deck_creator == null:
		deck_creator = creator

	stored_card_id = data.card_id
	card_face.texture = data.card_background
	card_overlay.texture = data.card_overlay

	title.text = data.display_title
	cost.add_theme_color_override("font_color", data.cost_color)
	cost.text = data.cost_text
	unlock_button.disabled = not data.is_affordable


func _set_slider_percent(percent: float) -> void:
	if slider:
		slider.scale.x = clamp(percent, 0.0, 1.0)

func _process(delta: float) -> void:
	if is_holding:
		_handle_purchase_progress(delta)

func _handle_purchase_progress(delta: float) -> void:
	hold_timer += delta

	if unlock_button and not unlock_button.is_disabled():
		if hold_timer >= hold_delay:
			deck_creator.purchase_card(stored_card_id)
			_set_slider_percent(0.0)
			_reset_hold_state()
		else:
			var progress = hold_timer / hold_delay
			_set_slider_percent(min(progress, 1.0))

func _reset_hold_state() -> void:
	is_holding = false
	hold_timer = 0.0

# Handle unlock button input for purchase
func _on_button_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		is_holding = true
		hold_timer = 0.0
	
	if Input.is_action_just_released("ui_click"):
		# Show tooltip if quick tap or button disabled
		if _is_early_hold_release() or unlock_button.is_disabled():
			if deck_creator:
				deck_creator.show_card_tooltip(stored_card_id)
		_set_slider_percent(0.0)
		_reset_hold_state()

# Check if this was a quick tap (not a hold)
func _is_early_hold_release() -> bool:
	return hold_timer < (hold_delay / 2.0)