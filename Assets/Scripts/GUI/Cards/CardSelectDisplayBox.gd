extends Control
class_name CardSelectDisplayBox
## Card selection display box for deck creation
##
## Manages the display and interaction for individual cards in deck creation,
## handling both locked and unlocked states with appropriate UI elements.

#region Export Properties
@export var locked_display: CardSelectDisplayBoxLocked
@export var unlocked_display: CardSelectDisplayBoxUnlocked
#endregion

#region Properties
var stored_card: Card
var can_add: bool = true
var can_remove: bool = true

# Hold-to-purchase mechanics
var is_holding: bool = false
var hold_timer: float = 0.0
var hold_delay: float = GameConstants.HOLD_DELAY_DEFAULT
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button signals from unlocked display
func _connect_signals() -> void:
	if unlocked_display:
		unlocked_display.add_card_button.pressed.connect(_on_add_card_pressed)
		unlocked_display.remove_card_button.pressed.connect(_on_remove_card_pressed)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if unlocked_display:
		if unlocked_display.add_card_button.pressed.is_connected(_on_add_card_pressed):
			unlocked_display.add_card_button.pressed.disconnect(_on_add_card_pressed)
		if unlocked_display.remove_card_button.pressed.is_connected(_on_remove_card_pressed):
			unlocked_display.remove_card_button.pressed.disconnect(_on_remove_card_pressed)
#endregion

#region Update Loop
func _process(delta: float) -> void:
	if is_holding:
		_handle_purchase_progress(delta)
#endregion

#region Display Management
# Update the display based on card state and permissions
func update_display(card: Card, can_add_card: bool, can_remove_card: bool, deck_count: int = -1) -> void:
	stored_card = card
	_update_display_visibility(card)
	_configure_display_content(card, deck_count)
	_update_button_states(can_add_card, can_remove_card)

# Show appropriate display based on card unlock status
func _update_display_visibility(card: Card) -> void:
	if card.is_unlocked:
		locked_display.hide()
		unlocked_display.show()
	else:
		unlocked_display.hide()
		locked_display.show()

# Configure display content
func _configure_display_content(card: Card, deck_count: int) -> void:
	if card.is_unlocked and unlocked_display:
		unlocked_display.display(card, deck_count)
	elif not card.is_unlocked and locked_display:
		locked_display.display(card)

# Update button interaction states
func _update_button_states(can_add_card: bool, can_remove_card: bool) -> void:
	can_add = can_add_card
	can_remove = can_remove_card
	
	if unlocked_display:
		unlocked_display.stop_add(not can_add_card)
		unlocked_display.stop_remove(not can_remove_card)
#endregion

#region Card Actions
# Handle add card button press
func _on_add_card_pressed() -> void:
	if not can_add or not stored_card:
		return
	
	_add_card_to_deck()

# Handle remove card button press
func _on_remove_card_pressed() -> void:
	if not can_remove or not stored_card:
		return
	
	_remove_card_from_deck()

# Add card to deck through new architecture
func _add_card_to_deck() -> void:
	if ValidationUtils.has_event_bus():
		EventBus.emit_deck_modified(
			DataStructures.DeckOperation.ADD, 
			stored_card
		)
	print("Added card: ", Tools.get_card_title(stored_card))

# Remove card from deck through new architecture
func _remove_card_from_deck() -> void:
	if ValidationUtils.has_event_bus():
		EventBus.emit_deck_modified(
			DataStructures.DeckOperation.REMOVE, 
			stored_card
		)
	print("Removed card: ", Tools.get_card_title(stored_card))
#endregion

#region Purchase System
# Handle card purchase completion
func _purchase_card() -> void:
	if not stored_card:
		return
	
	# Update currency through new architecture
	if ValidationUtils.has_event_bus():
		EventBus.emit_currency_updated(
			-stored_card.unlock_cost,
			DataStructures.CurrencyType.CLAIRVOYANCE
		)
	
	# Unlock the card
	stored_card.is_unlocked = true
	
	# Reset hold state
	_reset_hold_state()

# Handle purchase progress during hold
func _handle_purchase_progress(delta: float) -> void:
	hold_timer += delta
	
	if locked_display and not locked_display.unlock_button.is_disabled():
		if hold_timer >= hold_delay:
			_purchase_card()
			locked_display.set_slider_percent(0.0)
		else:
			var progress = hold_timer / hold_delay
			locked_display.set_slider_percent(min(progress, 1.0))

# Reset hold state
func _reset_hold_state() -> void:
	is_holding = false
	hold_timer = 0.0
#endregion

#region Input Handling
# Handle card face input for tooltips
func _on_card_face_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_released("ui_click"):
		_show_card_tooltip()

# Handle unlock button input for purchase
func _on_button_gui_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		is_holding = true
		hold_timer = 0.0
	
	if Input.is_action_just_released("ui_click"):
		# Show tooltip if quick tap or button disabled
		if _is_early_hold_release() or _is_unlock_disabled():
			_show_card_tooltip()
		
		# Reset progress display and hold state
		if locked_display:
			locked_display.set_slider_percent(0.0)
		_reset_hold_state()

# Check if this was a quick tap (not a hold)
func _is_early_hold_release() -> bool:
	return hold_timer < (hold_delay / 2.0)

# Check if unlock button is disabled
func _is_unlock_disabled() -> bool:
	return locked_display and locked_display.unlock_button.is_disabled()

# Show tooltip for the stored card
func _show_card_tooltip() -> void:
	if stored_card and ValidationUtils.has_event_bus():
		EventBus.emit_tooltip_requested(stored_card, DataStructures.GameLayer.DECK)
#endregion