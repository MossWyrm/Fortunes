extends Node
## Main card display panel for showing drawn cards
##
## Handles the visual presentation of cards including animations, tooltips,
## and user interactions. Supports both regular cards and major arcana with
## different animation styles.

#region Export Properties
@export var default_card_texture: Texture2D
#endregion

#region Node References
@onready var card_title_label: Label = $Scroll/MarginContainer/card_text
@onready var major_title_label: Label = $MajorTextDisplay/VBoxContainer/card_text
@onready var card_background: TextureRect = $CardFront
@onready var card_overlay: TextureRect = $CardFront/FaceImage
@onready var card_animator: AnimationPlayer = $CardFlipAnimations
@onready var sparkle_animator: AnimationPlayer = $Sparkling
#endregion

#region Signals
signal animation_finished
#endregion

#region State Properties
var current_card: Card
var is_flipped: bool = false
var animation_done: bool = false:
	set(value):
		animation_done = value
		animation_finished.emit()

# Input handling
var is_holding: bool = false
var hold_timer: float = 0.0
var hold_duration: float = 0.8

# Major card state
var is_clearing_major: bool = false
var block_remove: bool = false
var signal_received: bool = false
var skip_card: bool = false
#endregion

#region Initialization
func _ready() -> void:
	_connect_event_bus_signals()
	_initialize_display()

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Connect to the new EventBus architecture
func _connect_event_bus_signals() -> void:
	EventBus.card_drawn.connect(_on_card_drawn)
	EventBus.clear_card.connect(_on_clear_card)
	EventBus.major_card_animation_requested.connect(_on_clear_major)
	EventBus.skip_chosen.connect(_on_card_skip)

# Disconnect all signals safely
func _disconnect_signals() -> void:
	EventBus.card_drawn.disconnect(_on_card_drawn)
	EventBus.clear_card.disconnect(_on_clear_card)
	EventBus.major_card_animation_requested.disconnect(_on_clear_major)
	EventBus.skip_chosen.disconnect(_on_card_skip)

# Initialize the display with default values
func _initialize_display() -> void:
	card_title_label.text = "~"
	major_title_label.text = "~"
	card_animator = $CardFlipAnimations
	sparkle_animator = $Sparkling
#endregion

#region Update Loop
func _process(delta: float) -> void:
	_handle_hold_input(delta)

# Handle press-and-hold for tooltip display
func _handle_hold_input(delta: float) -> void:
	if is_holding:
		hold_timer += delta
		if hold_timer >= hold_duration:
			_show_card_tooltip()
			_reset_hold_state()
#endregion

#region Card Display
# Handle new card being drawn
func _on_card_drawn(card: Card, flipped: bool) -> void:
	is_flipped = flipped
	current_card = card
	
	_set_card_visuals(card)
	
	if _is_major_card(card):
		_display_major_card(card)
	else:
		_display_regular_card(card, flipped)

# Set the card's texture and visual elements
func _set_card_visuals(card: Card) -> void:
	var textures = PreloadedResources.get_card_texture(card)
	
	if textures.is_empty():
		card_background.texture = default_card_texture
		return
	
	var background: Texture2D = textures.get("background")
	var overlay: Texture2D = textures.get("overlay")
	
	card_background.texture = background
	card_overlay.texture = overlay
	
	# Set atlas size if overlay has atlas
	if overlay and card_overlay.material and overlay.atlas:
		card_overlay.material.set("shader_parameter/atlas_size", overlay.atlas.get_size())

# Display a major arcana card with special effects
func _display_major_card(card: Card) -> void:
	block_remove = true
	major_title_label.text = Tools.get_card_title(card)
	_play_major_animation()

# Display a regular suit card
func _display_regular_card(card: Card, flipped: bool) -> void:
	card_title_label.text = Tools.get_card_title(card)
	_play_flip_animation(flipped)

# Check if the card is a major arcana card
func _is_major_card(card: Card) -> bool:
	return card.id >= GameConstants.MAJOR_CARD_THRESHOLD
#endregion

#region Animations
# Play the appropriate flip animation based on card state
func _play_flip_animation(flipped: bool) -> void:
	sparkle_animator.stop()
	
	if flipped:
		card_background.rotation = PI
		card_animator.play("CardDrawBad")
		_set_title_color(Color(0.712, 0.127, 0.128))  # Red for bad cards
	else:
		card_background.rotation = 0
		card_animator.play("CardDrawGood")
		_set_title_color(Color.BLACK)  # Black for good cards

# Play the major arcana card animation with sparkles
func _play_major_animation() -> void:
	card_background.rotation = 0
	card_animator.play("MajorDraw")
	sparkle_animator.play("sparkle")

# Set the card title color
func _set_title_color(color: Color) -> void:
	if card_title_label.label_settings:
		card_title_label.label_settings.font_color = color

# Called by animation player when draw animation completes
func finish_draw_animation() -> void:
	animation_done = true
	is_clearing_major = false
#endregion

#region Card Clearing
# Handle card clear request from EventBus
func _on_clear_card() -> void:
	if not _can_clear_card():
		return
	
	_reset_clear_state()
	
	if animation_done:
		if skip_card:
			_play_skip_animation()
		else:
			_play_return_animation()

# Check if the card can be cleared
func _can_clear_card() -> bool:
	if not current_card:
		return false
	
	# Major cards need special handling
	if _is_major_card(current_card) and block_remove and not signal_received:
		return false
	
	return true

# Reset clearing-related state variables
func _reset_clear_state() -> void:
	block_remove = false
	signal_received = false

# Play the skip card animation
func _play_skip_animation() -> void:
	_set_burn_color(Color.WHITE)
	card_animator.play("SkipCard")
	_reset_animation_state()

# Play the return card animation
func _play_return_animation() -> void:
	var burn_color = DataStructures.core_color.GOOD if not is_flipped else DataStructures.core_color.BAD
	_set_burn_color(burn_color)
	card_animator.play("ReturnCard")
	_reset_animation_state()

# Set the burn shader color for both background and overlay
func _set_burn_color(color: Color) -> void:
	for texture_rect in [card_background, card_overlay]:
		if texture_rect.material:
			texture_rect.material.set("shader_parameter/burn_color", color)

# Reset animation state after playing clear animation
func _reset_animation_state() -> void:
	animation_done = false
	skip_card = false

# Called by animation player when card clear animation completes
func card_cleared() -> void:
	animation_done = true
	EventBus.emit_card_animation_finished(current_card)
#endregion

#region Event Handlers
# Handle major card clear signal
func _on_clear_major(_flipped: bool) -> void:
	signal_received = true

# Handle skip choice signal
func _on_card_skip(skipped: bool) -> void:
	skip_card = skipped
	block_remove = false
	_on_clear_card()
#endregion

#region Input Handling
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

# Handle mouse/touch release
func _handle_release() -> void:
	if hold_timer < hold_duration and not _is_drawing_paused():
		_on_clear_card()
	_reset_hold_state()

# Reset hold input state
func _reset_hold_state() -> void:
	is_holding = false
	hold_timer = 0.0

# Show tooltip for the current card
func _show_card_tooltip() -> void:
	if current_card and ValidationUtils.has_event_bus():
		EventBus.emit_tooltip_requested(current_card, DataStructures.GameLayer.DECK)

# Check if card drawing is currently paused
func _is_drawing_paused() -> bool:
	if GameManager.game_state:
		return GameManager.game_state.is_paused
	return false
#endregion