extends Control

## Display Upgrade Button
## True one-way data flow: Controller sends complete display data,
## button only makes one call back to purchase an upgrade.

@onready var cost_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Cost
@onready var currency_icon: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrencyImage
@onready var title_description: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Title_Desc
@onready var progress_slider: ColorRect = $MASK/ColorRect
@onready var card_background: TextureRect = $MarginContainer/HBoxContainer/CardBack
@onready var card_overlay: TextureRect = $MarginContainer/HBoxContainer/CardBack/CardOverlay

var upgrade_id: String  # Only thing we need to store for purchase callback
var card_id: int = 0    # Card ID for tooltip display (0 if no associated card)
var is_purchaseable: bool = false

# Hold-to-purchase mechanics
var is_holding: bool = false
var hold_timer: float = 0.0
var hold_delay: float = GameConstants.HOLD_TO_PURCHASE_DELAY

# Touch gesture detection
var gesture_detector: TouchGestureDetector = TouchGestureDetector.new()

#region Public Methods
## Displays upgrade with complete pre-calculated data
func display(data: UpgradeDisplayData) -> void:
	upgrade_id = data.upgrade_id
	card_id = data.card_id
	is_purchaseable = data.is_purchaseable
	
	title_description.text = DescriptionFormatter.format_title_description(data.display_title, data.description)
	cost_label.text = data.cost_text
	cost_label.add_theme_color_override("font_color", data.cost_color)
	currency_icon.texture = data.currency_icon
	card_background.texture = data.card_background
	
	if data.card_overlay:
		card_overlay.texture = data.card_overlay
		card_overlay.show()
	else:
		card_overlay.hide()
		card_overlay.texture = null
#endregion

#region Update Loop
func _process(delta: float) -> void:
	if visible and is_holding:
		_handle_purchase_progress(delta)
#endregion

#region Purchase System
# Handle purchase progress during hold
func _handle_purchase_progress(delta: float) -> void:
	if not is_purchaseable or not is_holding:
		return
	
	hold_timer += delta
	
	if hold_timer >= hold_delay:
		_complete_purchase()
	else:
		_update_progress_display()

# Complete the purchase
func _complete_purchase() -> void:
	hold_timer = 0.0
	_set_progress_percent(0.0)

	if GameManager.game_state and GameManager.game_state.upgrade_manager:
		GameManager.game_state.upgrade_manager.purchase_upgrade(upgrade_id)

# Update progress slider display
func _update_progress_display() -> void:
	var progress = hold_timer / hold_delay
	_set_progress_percent(min(progress, 1.0))

# Set progress slider percentage
func _set_progress_percent(percent: float) -> void:
	progress_slider.scale.x = percent
#endregion

#region Input Handling
# Handle GUI interaction for mobile-friendly tooltip and purchase
func on_gui_interact(event: InputEvent) -> void:
	var result = gesture_detector.process_input(event)
	match result.gesture_type:
		TouchGestureDetector.GestureResult.GestureType.TOUCH_STARTED:
			# Touch/click started - start potential hold for purchase if purchaseable
			if is_purchaseable:
				_start_hold()
		
		TouchGestureDetector.GestureResult.GestureType.TAP_COMPLETED:
			# Intentional tap without dragging - always show tooltip
			if is_holding:
				# Was holding but released early - show tooltip instead of purchase
				_show_card_tooltip()
				_end_hold()
			else:
				# Quick tap - show tooltip
				_show_card_tooltip()
		
		TouchGestureDetector.GestureResult.GestureType.DRAG_COMPLETED:
			# Drag gesture completed (was scrolling) - don't show tooltip
			if is_holding:
				_end_hold()
		
		TouchGestureDetector.GestureResult.GestureType.DRAGGING:
			# Currently dragging - no action needed
			pass

# Start hold timer
func _start_hold() -> void:
	is_holding = true
	hold_timer = 0.0

# End hold and reset state
func _end_hold() -> void:
	_set_progress_percent(0.0)
	is_holding = false
	hold_timer = 0.0

# Show card tooltip if this upgrade has an associated card
func _show_card_tooltip() -> void:
	if card_id <= 0:
		return
	if not ValidationUtils.has_deck_manager():
		return
	var card = GameManager.game_state.deck_manager.get_card(card_id)
	if card:
		EventBus.emit_tooltip_requested(card, DataStructures.GameLayer.DECK)
#endregion
