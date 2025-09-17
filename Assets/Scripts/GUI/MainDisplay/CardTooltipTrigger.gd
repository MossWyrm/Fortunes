extends Control
class_name CardTooltipTrigger

## Card tooltip trigger component
## Detects user input for displaying card tooltips.

var current_card: Card
var is_holding: bool = false
var hold_timer: float = 0.0
var hold_duration: float = 0.5

func _set_card(card: Card) -> void:
	current_card = card

func _ready():
	gui_input.connect(press_and_hold)
	EventBus.card_drawn.connect(_on_card_drawn)

func _process(delta: float) -> void:
	_handle_hold_input(delta)

# Handle press-and-hold for tooltip display
func _handle_hold_input(delta: float) -> void:
	if is_holding:
		hold_timer += delta
		if hold_timer >= hold_duration:
			_show_card_tooltip()
			_reset_hold_state()

# Handle press and hold input for card interactions
func press_and_hold(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		_start_hold()
	elif Input.is_action_just_released("ui_click"):
		_handle_release()

# Start the hold timer
func _start_hold() -> void:
	is_holding = true
	hold_timer = 0.0

# Clear card if released before hold duration
func _handle_release() -> void:
	if hold_timer <= hold_duration:
		EventBus.emit_clear_card()
	_reset_hold_state()

# Reset hold input state
func _reset_hold_state() -> void:
	is_holding = false
	hold_timer = 0.0

# Show tooltip for the current card
func _show_card_tooltip() -> void:
	if current_card:
		EventBus.emit_tooltip_requested(current_card, DataStructures.GameLayer.DECK)

# Check if card drawing is currently paused
func _is_drawing_paused() -> bool:
	if GameManager.game_state:
		return GameManager.game_state.is_paused
	return false

func _on_card_drawn(card: Card, _flipped: bool) -> void:
	_set_card(card)