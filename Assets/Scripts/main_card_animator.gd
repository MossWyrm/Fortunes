extends Node
class_name MainCardAnimator

@export var burn_overlay: ShaderMaterial
@export var burn_front: ShaderMaterial
@export var ghost_overlay: ShaderMaterial
@export var ghost_front: ShaderMaterial

# References
@onready var _card_back: TextureRect = $"../CardBack"
@onready var _card_front: TextureRect = $"../CardFront"
@onready var _card_overlay: TextureRect = $"../CardFront/FaceImage"
@onready var _color_overlay: ColorRect = $"../CardFront/MASK/ColorOverlay"
@onready var _major_text: Control = $"../../../CardTextDisplays/MajorTextDisplay"
@onready var _basic_text: TextureRect = $"../../../CardTextDisplays/Scroll"
@onready var _shine: ColorRect = $"../CardFront/FaceImage/Shine"


# Animation Config
var auto_draw_speed: float:
	get:
		if not ValidationUtils.has_stats():
			DebugManager.log_warning("Animator is waiting for stats to be ready", DebugManager.DebugCategory.CARD_ANIMATIONS)
			return 0
		return GameManager.game_state.stats.pack_auto_draw_speed

var animation_duration: float:
	get:
		return (0.8 if (auto_draw_speed / 2.0) > 0.8 else (auto_draw_speed / 2.0)) # Total animation time - adjust this value!
const FLIP_TIME_RATIO: float = 0.7     # 70% for card flip sequence
const EMPHASIS_TIME_RATIO: float = 0.3 # 30% for emphasis sequence
const GHOST_PADDING: int = 50          # Pixels of breathing space for ghost shader
const EMPHASIS_SCALE: float = 1.1      # Scale factor for emphasis animations
const BURN_SCALE: float = 1.2          # Scale factor for burn animations
const FLASH_ALPHA: float = 0.6         # Alpha for color flash effects

# State Management
var is_animating: bool:
	get:
		return is_animating
	set(value):
		if value == true:
			is_animating = true
			await animation_finished
			is_animating = false
var is_displayed: bool
var _is_player_input_pending: bool = false
var _input_already_processed: bool = false
var _should_shuffle_after_return: bool = false
var _is_requested_shuffle_safe: bool = false

# Current Animation Context
var _saved_card: Card
var _current_animation_type: DataStructures.CardAnimationType
var _major_flipped: bool

# High Priestess Transform State
var _high_priestess_transform: bool = false
var _high_priestess_textures: Dictionary = {}
var _high_priestess_chosen_card: Card

# Colors and Effects
var _bad_color: Color = DataStructures.core_color.BAD
var _good_color: Color = DataStructures.core_color.GOOD
var _shine_tween: Tween

# Public API
signal animation_finished

# Lifecycle Methods
func _ready():
	_setup_signals()
	_reset_state()

#region Public API Methods

## Main entry point for card animations
func animate_card(type: DataStructures.CardAnimationType, card: Card, flipped: bool) -> void:
	if is_animating or is_displayed:
		_log_animation("Animator busy or card already displayed, ignoring animation request")
		return
	
	_saved_card = card
	_current_animation_type = type
	is_animating = true
	_log_animation("Starting animation type: " + str(type))
	_setup_card_display(card, flipped)
	
	match type:
		DataStructures.CardAnimationType.BASIC_CARD:
			await _play_basic_flip_anim(flipped)
			EventBus.emit_animation_step_completed("flip_complete")
			
		DataStructures.CardAnimationType.MAJOR_CARD:
			_major_flipped = flipped
			await _play_major_flip_anim()
			EventBus.emit_animation_step_completed("flip_complete")
			
		DataStructures.CardAnimationType.GHOST_NEGATIVE:
			await _play_ghost_flip_anim()
			EventBus.emit_animation_step_completed("ghost_complete")
			# Transform happens after forced choice is made in _on_high_priestess_card_chosen
			
		DataStructures.CardAnimationType.GHOST_POSITIVE:
			await _play_ghost_flip_anim()
			EventBus.emit_animation_step_completed("ghost_complete")
			# For positive, transform happens when player makes choice (in _on_high_priestess_card_chosen)
	
	is_displayed = true

## Legacy method for compatibility - redirects to animate_card
func flip_card(card: Card, flipped: bool) -> void:
	_log_animation("Legacy flip_card called - redirecting to animation system")
	var type = DataStructures.CardAnimationType.BASIC_CARD
	if card.suit == DataStructures.SuitType.MAJOR:
		type = DataStructures.CardAnimationType.MAJOR_CARD
	animate_card(type, card, flipped)

## Returns the currently displayed card with appropriate animation
func return_card() -> void:
	_log_animation("return_card called - is_animating: %s, is_displayed: %s, _is_player_input_pending: %s" % [is_animating, is_displayed, _is_player_input_pending])
	if is_animating or not is_displayed or _is_player_input_pending:
		_log_animation("Ignoring return request")
		return
	if _high_priestess_transform:
		_play_high_priestess_transform()
		await animation_finished
	is_animating = true
	_log_animation("Returning card")
	if _saved_card.suit == DataStructures.SuitType.MAJOR:
		await _play_major_return()
	else:
		await _play_basic_return()
	is_displayed = false
	# Trigger shuffle animation if requested
	if _should_shuffle_after_return:
		await shuffle_deck()
	EventBus.emit_card_animation_finished()

## Animates deck shuffling
func shuffle_deck() -> void:
	if is_animating or is_displayed:
		_log_animation("Ignoring shuffle request")
		return
	is_animating = true
	_log_animation("Shuffling deck")
	await _play_shuffle_animation()
	_should_shuffle_after_return = false

## Skips the current card with burn animation
func skip_card() -> void:
	if is_animating:
		_log_animation("Ignoring skip request")
		return
	is_animating = true
	_log_animation("Skipping card")
	_set_burn_color(Color.WHITE)
	var tween = create_tween()
	tween.tween_property(_card_front, "scale", Vector2(0,0), animation_duration)
	tween.parallel().tween_property(_card_front, "material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_card_overlay, "material:shader_parameter/burn_amount", 1.0, animation_duration)
	var object = _basic_text if _saved_card.suit != DataStructures.SuitType.MAJOR else _major_text
	tween.parallel().tween_property(object, "modulate", Color(1,1,1,0), animation_duration)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	is_displayed = false
	_reset_state()
	if _should_shuffle_after_return:
		await shuffle_deck()
	EventBus.emit_card_animation_finished()

#endregion

#region Private Setup and Configuration

func _setup_signals() -> void:
	animation_finished.connect(func() -> void:
		_log_animation("Animation finished")
	)
	# Animation system
	EventBus.animation_requested.connect(animate_card)
	# Card lifecycle
	EventBus.clear_card.connect(return_card)
	# Input management
	EventBus.player_input_requested.connect(_on_player_input_requested)
	EventBus.player_input_received.connect(_on_player_input_received)
	# Deck management
	EventBus.request_shuffle.connect(_on_shuffle_requested)
	# High Priestess system
	EventBus.card_choice_requested.connect(_on_high_priestess_triggered)
	EventBus.card_chosen.connect(_on_high_priestess_card_chosen)
	# Skip system
	EventBus.skip_chosen.connect(_on_skip_chosen)
	

func _setup_card_display(card: Card, flipped: bool) -> void:
	_card_overlay.show()
	_card_front.show()
	
	var texture_dict = PreloadedResources.get_card_texture(card)
	_card_front.texture = texture_dict["background"]
	_card_overlay.texture = texture_dict["overlay"]

	var title = Tools.get_card_title(card)
	if card.suit == DataStructures.SuitType.MAJOR:
		_card_front.rotation = 0
		_major_text.get_node("VBoxContainer/card_text").text = title
		_major_text.show()
	else:
		_card_front.rotation_degrees = 180 if flipped else 0
		_basic_text.get_node("MarginContainer/card_text").text = title
		_basic_text.show()
	
	# Set up burn materials by default
	var burn_color = _bad_color if flipped else _good_color
	_set_material_burn(0.0)
	_set_burn_color(burn_color)

func _reset_state() -> void:
	_card_back.scale = Vector2(1,1)
	_card_back.modulate = Color(1,1,1,1)
	_card_back.hide()
	_card_front.hide()
	_card_overlay.hide()
	
	# Reset to burn materials and clear any transformations
	_set_material_burn(0.0)
	
	_card_front.scale = Vector2(0,1)
	_card_front.modulate = Color(1,1,1,1)
	_card_overlay.modulate = Color(1,1,1,1)
	_basic_text.hide()
	_basic_text.scale = Vector2(0,1)
	_basic_text.modulate = Color(1,1,1,1)
	_major_text.hide()
	_major_text.scale = Vector2(0,1)
	_major_text.modulate = Color(1,1,1,1)
	_color_overlay.color = Color(1,1,1,0)
	_disable_shine()

#endregion

#region Core Animation Implementations

func _play_basic_flip_anim(flipped: bool) -> void:
	_log_animation("Starting basic card animation")
	var tween = create_tween()
	_animate_card_reveal(tween)
	_animate_emphasis_and_flash(tween, flipped)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_card_back.scale = Vector2(1,1)

func _play_major_flip_anim() -> void:
	_log_animation("Starting major card animation")
	var tween = create_tween()
	_enable_shine(true)
	_animate_card_reveal(tween)
	_animate_emphasis_only(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_card_back.scale = Vector2(1,1)

func _play_ghost_flip_anim() -> void:
	_log_animation("Starting ghost card animation")
	var tween = create_tween()
	_animate_ghost_card_reveal(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()

func _play_high_priestess_transform() -> void:
	_set_ghost_textures()
	
	# Update text to show the transformed card and set initial scale
	var transformed_title = Tools.get_card_title(_high_priestess_chosen_card)
	_basic_text.get_node("MarginContainer/card_text").text = transformed_title
	_basic_text.scale = Vector2(0, 0)  # Start scaled down
	
	# Start the ripple transition
	var tween = create_tween()
	_set_material_ghost(0.0)  # Initialize ghost material with no transition
	
	# Animate the ripple effect and text scaling in parallel
	tween.tween_method(_set_material_ghost, 0.0, 1.0, animation_duration)
	tween.parallel().tween_property(_basic_text, "scale", Vector2(1, 1), animation_duration)
	await tween.finished
	
	# Switch to final textures and burn material
	_card_front.texture = _high_priestess_textures["background"]
	_card_overlay.texture = _high_priestess_textures["overlay"]
	_set_material_burn(0.0)  # Switch to burn material with no burn
	
	tween.kill()
	animation_finished.emit()
	_high_priestess_transform = false

func _play_basic_return() -> void:
	_log_animation("Starting basic card return animation")
	var tween = create_tween()
	_animate_basic_burn_and_fade(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_reset_state()

func _play_major_return() -> void:
	_log_animation("Starting major card return animation")
	var tween = create_tween()
	EventBus.emit_request_vfx(DataStructures.VFXType.CARD_FAILURE if _major_flipped else DataStructures.VFXType.CARD_SUCCESS)
	_animate_major_scale_and_fade(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_reset_state()

func _play_shuffle_animation() -> void:
	_log_animation("Starting shuffle animation")
	var loops = 3
	var tween = create_tween().set_loops(loops).set_ease(Tween.EASE_OUT)
	var shuffle_color = DataStructures.core_color.GOOD if _is_requested_shuffle_safe else DataStructures.core_color.BAD
	shuffle_color.a = 0.2
	_card_back.scale = Vector2(1,1)
	_card_back.show()
	tween.tween_property(_card_back, "scale", Vector2(1.1,1.1), animation_duration / loops )
	tween.parallel().tween_property(_card_back,"modulate", shuffle_color, animation_duration / loops)
	tween.loop_finished.connect(func(_x):
		_card_back.scale = Vector2(1,1)
		_card_back.modulate = Color(1,1,1,1)
	)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_reset_state()

#endregion

#region Animation Building Blocks

## Handles the main card flip sequence - back shrinks, front/text appears
func _animate_card_reveal(tween: Tween) -> void:
	var flip_time = _get_flip_time()

	_card_back.show()
	_card_front.show()
	_card_overlay.show()
	
	var text_element = _major_text if _saved_card.suit == DataStructures.SuitType.MAJOR else _basic_text
	text_element.show()

	tween.tween_property(_card_back, "scale", Vector2(0,1), flip_time)
	tween.tween_property(_card_front, "scale", Vector2(1,1), flip_time)
	tween.parallel().tween_property(text_element, "scale", Vector2(1,1), flip_time)

func _animate_ghost_card_reveal(tween: Tween) -> void:
	var flip_time = _get_flip_time()
	
	_set_material_ghost()

	_card_back.show()
	_card_front.show()
	_card_overlay.show()

	tween.tween_property(_card_back, "scale", Vector2(0,1), flip_time)
	tween.tween_property(_card_front, "scale", Vector2(1,1), flip_time)

## Handles emphasis animation plus color flash for basic cards
func _animate_emphasis_and_flash(tween: Tween, flipped: bool) -> void:
	var emphasis_time = _get_emphasis_time()
	var flash_color = _bad_color if flipped else _good_color
	flash_color.a = FLASH_ALPHA

	tween.tween_property(_color_overlay, "color", flash_color, emphasis_time*2)
	tween.parallel().tween_property(_card_front, "scale", Vector2(EMPHASIS_SCALE, EMPHASIS_SCALE), emphasis_time)
	tween.tween_property(_card_front, "scale", Vector2(1, 1), emphasis_time)
	flash_color.a = 0
	tween.tween_property(_color_overlay, "color", flash_color, emphasis_time*2)

## Handles emphasis animation only (for major cards)
func _animate_emphasis_only(tween: Tween) -> void:
	var emphasis_time = _get_emphasis_time()
	tween.tween_property(_card_front, "scale", Vector2(EMPHASIS_SCALE, EMPHASIS_SCALE), emphasis_time)
	tween.tween_property(_card_front, "scale", Vector2(1, 1), emphasis_time)

## Basic Cards: scale up while burning and fade text
func _animate_basic_burn_and_fade(tween: Tween) -> void:
	tween.tween_property(_card_front, "scale", Vector2(BURN_SCALE, BURN_SCALE), animation_duration)
	tween.parallel().tween_property(_card_front,"material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_card_overlay,"material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_basic_text, "scale", Vector2(BURN_SCALE, BURN_SCALE), animation_duration)
	tween.parallel().tween_property(_basic_text, "modulate", Color(1,1,1,0), animation_duration)

## Major Cards: scale up with color flash, then fade out
func _animate_major_scale_and_fade(tween: Tween) -> void:
	var color_change = animation_duration * 0.4
	var fade_time = animation_duration * 0.6
	var flash_color = _bad_color if _major_flipped else _good_color
	flash_color.a = FLASH_ALPHA
	
	tween.tween_property(_card_front, "scale", Vector2(BURN_SCALE, BURN_SCALE), animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_major_text, "scale", Vector2(BURN_SCALE, BURN_SCALE), animation_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_major_text, "modulate", Color(1,1,1,0), animation_duration)
	tween.parallel().tween_property(_card_front,"modulate", Color(1,1,1,0), animation_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_color_overlay, "color", flash_color, color_change)
	flash_color.a = 0
	tween.tween_property(_color_overlay, "color", flash_color, fade_time)
	tween.set_trans(Tween.TRANS_LINEAR)

#endregion

#region Utility and Helper Methods

func _get_flip_time() -> float:
	return animation_duration * FLIP_TIME_RATIO * 0.5

func _get_emphasis_time() -> float:
	return animation_duration * EMPHASIS_TIME_RATIO * 0.5

func _log_animation(message: String) -> void:
	DebugManager.print_card_animations("Main Card Animator: " + message)

func _is_high_priestess_choice_case() -> bool:
	return _current_animation_type == DataStructures.CardAnimationType.GHOST_POSITIVE or _current_animation_type == DataStructures.CardAnimationType.GHOST_NEGATIVE

func _enable_shine(enabled: bool) -> void:
	if enabled:
		_shine_tween = create_tween().set_loops()
		_shine_tween.tween_property(_shine, "position", Vector2(784.0, 36.0), 1.0)
		_shine_tween.tween_interval(3)
		_shine_tween.loop_finished.connect(func(_x): _shine.position = Vector2(112.0, -353.0))
		_shine.show()
	else:
		_disable_shine()

func _disable_shine() -> void:
	_shine.hide()
	if _shine_tween:
		_shine_tween.kill()
		_shine_tween = null

#endregion

#region Event Handlers

func _on_player_input_requested() -> void:
	_is_player_input_pending = true
	_input_already_processed = false  # Reset the flag when new input is requested

func _on_player_input_received() -> void:
	# Prevent double processing due to EventBus race condition
	if _input_already_processed:
		_log_animation("Input already processed, ignoring player_input_received")
		return
		
	_is_player_input_pending = false
	# Only auto-return if this isn't a High Priestess choice case and we're not skipping
	if not _is_high_priestess_choice_case():
		_input_already_processed = true
		return_card()

func _on_shuffle_requested(safely: bool) -> void:
	_is_requested_shuffle_safe = safely
	_should_shuffle_after_return = true
	await get_tree().process_frame
	if not is_displayed and not is_animating:
		await shuffle_deck()

func _on_high_priestess_triggered(_cards: Array[Card]) -> void:
	_high_priestess_transform = true

func _on_high_priestess_card_chosen(card: Card) -> void:
	# Mark input as processed to prevent race conditions
	_input_already_processed = true
	_is_player_input_pending = false
	
	# Store the chosen card and its textures
	_high_priestess_chosen_card = card
	_high_priestess_textures = PreloadedResources.get_card_texture(card)
	
	if _current_animation_type == DataStructures.CardAnimationType.GHOST_NEGATIVE:
		# For GHOST_NEGATIVE: Transform immediately after forced card selection
		await _play_high_priestess_transform()
	elif _current_animation_type == DataStructures.CardAnimationType.GHOST_POSITIVE:
		# For GHOST_POSITIVE: Mark for transform and call return_card manually
		_high_priestess_transform = true
		return_card()

func _on_skip_chosen(should_skip: bool) -> void:
	# Mark input as processed to prevent race condition with player_input_received
	_input_already_processed = true
	_is_player_input_pending = false
	
	if should_skip:
		_log_animation("Skip chosen - calling skip_card instead of return_card")
		skip_card()
	else:
		_log_animation("Skip not chosen - calling return_card normally") 
		return_card()

#endregion

#region Material and Shader Management

func _set_material_burn(burn_amount: float = 0.0) -> void:
	# Reset any ghost material transformations first
	_reset_ghost_transformations()
	
	# Apply burn materials
	_card_front.material = burn_front
	_card_overlay.material = burn_overlay
	
	# Set burn parameters
	_card_front.material.set_shader_parameter("burn_amount", burn_amount)
	_card_overlay.material.set_shader_parameter("burn_amount", burn_amount)
	
	# Ensure proper pivot points for burn animations
	_card_front.pivot_offset = _card_front.size / 2
	_card_overlay.pivot_offset = _card_overlay.size / 2

func _set_material_ghost(transition_amount: float = 0.0) -> void:
	# Apply ghost materials
	_card_front.material = ghost_front
	_card_overlay.material = ghost_overlay
	
	# Setup ghost transformations and parameters
	_setup_ghost_transformations()
	
	# Set ghost parameters
	_card_front.material.set_shader_parameter("transition_active", transition_amount > 0.0)
	_card_overlay.material.set_shader_parameter("transition_active", transition_amount > 0.0)
	_card_front.material.set_shader_parameter("ripple_progress", transition_amount)
	_card_overlay.material.set_shader_parameter("ripple_progress", transition_amount)

func _set_burn_color(color: Color) -> void:
	for texture_rect in [_card_front, _card_overlay]:
		if texture_rect.material:
			DebugManager.print_card_animations("set %s to %s" % [texture_rect.name, color])
			texture_rect.material.set("shader_parameter/burn_color", color)

func _setup_ghost_transformations() -> void:
	_apply_ghost_transform_to_rect(_card_front, false)  # Front gets resized
	_apply_ghost_transform_to_rect(_card_overlay, true)  # Overlay skips resize

func _apply_ghost_transform_to_rect(texture_rect: TextureRect, skip_resize: bool = false) -> void:
	# Store original values if not already stored
	if not texture_rect.has_meta("original_position"):
		texture_rect.set_meta("original_position", texture_rect.position)
	if not texture_rect.has_meta("original_size"):
		texture_rect.set_meta("original_size", texture_rect.size)
	if not texture_rect.has_meta("original_clip"):
		texture_rect.set_meta("original_clip", texture_rect.clip_contents)
	
	# Store whether this rect was resized for proper restoration
	texture_rect.set_meta("was_resized", not skip_resize)

	var original_position = texture_rect.get_meta("original_position")
	var original_size = texture_rect.get_meta("original_size")
	
	# Disable clipping to allow overflow
	texture_rect.clip_contents = false

	if not skip_resize:
		# Expand size and adjust position to create breathing space
		texture_rect.size = original_size + Vector2(GHOST_PADDING * 2, GHOST_PADDING * 2)
		texture_rect.position = original_position - Vector2(GHOST_PADDING, GHOST_PADDING)
		texture_rect.pivot_offset = texture_rect.size / 2
	else:
		# Just set pivot for non-resized rects
		texture_rect.pivot_offset = texture_rect.size / 2

	# Apply shader parameters
	texture_rect.material.set_shader_parameter("original_size", original_size)
	texture_rect.material.set_shader_parameter("padding_pixels", float(GHOST_PADDING))

func _reset_ghost_transformations() -> void:
	for texture_rect in [_card_front, _card_overlay]:
		_reset_ghost_transform_for_rect(texture_rect)

func _reset_ghost_transform_for_rect(texture_rect: TextureRect) -> void:
	# Only restore values that were actually changed
	var was_resized = texture_rect.get_meta("was_resized", false)
	
	if was_resized and texture_rect.has_meta("original_size"):
		texture_rect.size = texture_rect.get_meta("original_size")
	if was_resized and texture_rect.has_meta("original_position"):
		texture_rect.position = texture_rect.get_meta("original_position")
	if texture_rect.has_meta("original_clip"):
		texture_rect.clip_contents = texture_rect.get_meta("original_clip")
	
	# Reset pivot to standard
	texture_rect.pivot_offset = texture_rect.size / 2

func _set_ghost_textures() -> void:
	if _high_priestess_textures.size() <= 0:
		DebugManager.print_card_animations("High Priestess textures not set, cannot transform card", DebugManager.DebugLevel.WARNING)
		return
	var atlas_texture: AtlasTexture = _high_priestess_textures["overlay"]
	_card_front.material.set_shader_parameter("new_texture", _high_priestess_textures["background"])
	_card_overlay.material.set_shader_parameter("new_texture", _high_priestess_textures["overlay"])
	_card_overlay.material.set_shader_parameter("new_using_atlas", true)
	_card_overlay.material.set_shader_parameter("new_sprite_size", atlas_texture.region.size)
	_card_overlay.material.set_shader_parameter("new_atlas_size", atlas_texture.atlas.get_size())
	_card_overlay.material.set_shader_parameter("new_atlas_offset", atlas_texture.region.position / atlas_texture.atlas.get_size())

#endregion