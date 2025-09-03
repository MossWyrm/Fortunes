extends Node
class_name MainCardAnimator

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
const FLIP_TIME_RATIO: float = 0.7    # 70% for card flip sequence
const EMPHASIS_TIME_RATIO: float = 0.3 # 30% for emphasis sequence

# Variables
var _bad_color: Color = DataStructures.core_color.BAD
var _good_color: Color = DataStructures.core_color.GOOD
var _shine_tween: Tween
var _major_flipped: bool
var _saved_card: Card
var _is_player_input_pending: bool = false

# Public API
signal animation_finished
var is_animating: bool:
	get:
		return is_animating
	set(value):
		if value == true:
			is_animating = true
			await animation_finished
			is_animating = false

var is_displayed: bool

# Lifecycle Methods
func _ready():
	_cleanup()
	_connect_signals()

func _connect_signals() -> void:
	animation_finished.connect(func() -> void:
		DebugManager.print_card_animations("Main Card Animator: Animation finished")
	)
	EventBus.card_drawn.connect(flip_card)
	EventBus.clear_card.connect(return_card)
	EventBus.player_input_requested.connect(_on_player_input_requested)
	EventBus.player_input_received.connect(_on_player_input_received)

# Public Methods
func flip_card(card: Card, flipped: bool) -> void:
	_saved_card = card
	if is_animating or is_displayed:
		DebugManager.print_card_animations("Main Card Animator: Animator busy or card already displayed, ignoring flip request")
		return
	is_animating = true
	DebugManager.print_card_animations("Main Card Animator: Flipping card")
	_setup_card_display(card, flipped)
	
	if card.suit == DataStructures.SuitType.MAJOR:
		_major_flipped = flipped
		await _play_major_flip_anim()
	else:
		await _play_basic_flip_anim(flipped)
	is_displayed = true

func return_card() -> void:
	if is_animating or not is_displayed or _is_player_input_pending:
		DebugManager.print_card_animations("Main Card Animator: Ignoring return request")
		return
	is_animating = true
	DebugManager.print_card_animations("Main Card Animator: Returning card")
	if _saved_card.suit == DataStructures.SuitType.MAJOR:
		await _play_major_return()
	else:
		await _play_basic_return()
	is_displayed = false
	EventBus.emit_card_animation_finished()

func skip_card() -> void:
	if is_animating:
		DebugManager.print_card_animations("Main Card Animator: Ignoring skip request")
		return
	is_animating = true
	DebugManager.print_card_animations("Main Card Animator: Skipping card")
	_set_burn_color(Color.WHITE)
	var tween = create_tween()
	tween.tween_property(_card_front, "scale", Vector2(0,0), animation_duration)
	tween.parallel().tween_property(_card_overlay, "scale", Vector2(0,0), animation_duration)
	tween.parallel().tween_property(_card_front, "material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_card_overlay, "material:shader_parameter/burn_amount", 1.0, animation_duration)
	var object = _basic_text if _saved_card.suit != DataStructures.SuitType.MAJOR else _major_text
	tween.parallel().tween_property(object, "modulate", Color(1,1,1,0), animation_duration)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_cleanup()
	EventBus.emit_card_animation_finished()

# Main Animation Functions
func _play_basic_flip_anim(flipped: bool) -> void:
	DebugManager.print_card_animations("Main Card Animator: Starting basic card animation")
	var tween = create_tween()
	_animate_card_reveal(tween)
	_animate_emphasis_and_flash(tween, flipped)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_card_back.scale = Vector2(1,1)

func _play_major_flip_anim() -> void:
	DebugManager.print_card_animations("Main Card Animator: Starting major card animation")
	var tween = create_tween()
	_enable_shine(true)
	_animate_card_reveal(tween)
	_animate_emphasis_only(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_card_back.scale = Vector2(1,1)

func _play_basic_return() -> void:
	DebugManager.print_card_animations("Main Card Animator: Starting basic card return animation")
	var tween = create_tween()
	_animate_basic_burn_and_fade(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_cleanup()

func _play_major_return() -> void:
	DebugManager.print_card_animations("Main Card Animator: Starting major card return animation")
	var tween = create_tween()
	EventBus.emit_request_vfx(DataStructures.VFXType.CARD_FAILURE if _major_flipped else DataStructures.VFXType.CARD_SUCCESS)
	_animate_major_scale_and_fade(tween)
	await tween.finished
	tween.kill()
	animation_finished.emit()
	_cleanup()

# helpers
func _get_flip_time() -> float:
	return animation_duration * FLIP_TIME_RATIO * 0.5

func _get_emphasis_time() -> float:
	return animation_duration * EMPHASIS_TIME_RATIO * 0.5

# animation blocks
##Handles the main card flip sequence - back shrinks, front/text appears
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

## Handles emphasis animation plus color flash for basic cards
func _animate_emphasis_and_flash(tween: Tween, flipped: bool) -> void:
	var emphasis_time = _get_emphasis_time()
	var flash_color = _bad_color if flipped else _good_color
	flash_color.a = 0.6

	tween.tween_property(_color_overlay, "color", flash_color, emphasis_time*2)
	tween.parallel().tween_property(_card_front, "scale", Vector2(1.1, 1.1), emphasis_time)
	tween.tween_property(_card_front, "scale", Vector2(1, 1), emphasis_time)
	flash_color.a = 0
	tween.tween_property(_color_overlay, "color", flash_color, emphasis_time*2)

## Handles emphasis animation only (for major cards)
func _animate_emphasis_only(tween: Tween) -> void:
	var emphasis_time = _get_emphasis_time()
	tween.tween_property(_card_front, "scale", Vector2(1.1, 1.1), emphasis_time)
	tween.tween_property(_card_front, "scale", Vector2(1, 1), emphasis_time)

## Basic Cards: scale up while burning and fade text
func _animate_basic_burn_and_fade(tween: Tween) -> void:
	tween.tween_property(_card_front, "scale", Vector2(1.2,1.2), animation_duration)
	tween.parallel().tween_property(_card_front,"material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_card_overlay,"material:shader_parameter/burn_amount", 1.0, animation_duration)
	tween.parallel().tween_property(_basic_text, "scale", Vector2(1.2,1.2), animation_duration)
	tween.parallel().tween_property(_basic_text, "modulate", Color(1,1,1,0), animation_duration)

## Major Cards: scale up with color flash, then fade out
func _animate_major_scale_and_fade(tween: Tween) -> void:
	var color_change = animation_duration * 0.4
	var fade_time = animation_duration * 0.6
	var flash_color = _bad_color if _major_flipped else _good_color
	flash_color.a = 0.6
	
	tween.tween_property(_card_front, "scale", Vector2(1.2,1.2), animation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_major_text, "scale", Vector2(1.2,1.2), animation_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(_major_text, "modulate", Color(1,1,1,0), animation_duration)
	tween.parallel().tween_property(_card_front,"modulate", Color(1,1,1,0), animation_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(_color_overlay, "color", flash_color, color_change)
	flash_color.a = 0
	tween.tween_property(_color_overlay, "color", flash_color, fade_time)
	tween.set_trans(Tween.TRANS_LINEAR)

# Event Listeners
func _on_player_input_requested() -> void:
	_is_player_input_pending = true

func _on_player_input_received() -> void:
	_is_player_input_pending = false

# Setup & Utility
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
	
	var burn_color = _bad_color if flipped else _good_color
	_set_burn_color(burn_color)

func _set_burn_color(color: Color) -> void:
	for texture_rect in [_card_front, _card_overlay]:
		if texture_rect.material:
			DebugManager.print_card_animations("set %s to %s" % [texture_rect.name, color])
			texture_rect.material.set("shader_parameter/burn_color", color)

func _enable_shine(enabled: bool) -> void:
	if enabled:
		_shine_tween = create_tween().set_loops()
		_shine_tween.tween_property(_shine, "position", Vector2(784.0, 36.0), 1.0)
		_shine_tween.tween_interval(3)
		_shine_tween.loop_finished.connect(func(_x): _shine.position = Vector2(112.0, -353.0))
		_shine.show()
	else:
		_shine.hide()
		if _shine_tween:
			_shine_tween.kill()
			_shine_tween = null

func _cleanup() -> void:
	_card_back.scale = Vector2(1,1)
	_card_front.hide()
	_card_front.pivot_offset = _card_front.size / 2
	_card_front.scale = Vector2(0,1)
	_card_front.modulate = Color(1,1,1,1)
	_card_front.material.set_shader_parameter("burn_amount", 0.0)
	_card_overlay.hide()
	_card_overlay.modulate = Color(1,1,1,1)
	_card_overlay.material.set_shader_parameter("burn_amount", 0.0)
	_basic_text.hide()
	_basic_text.scale = Vector2(0,1)
	_basic_text.modulate = Color(1,1,1,1)
	_major_text.hide()
	_major_text.scale = Vector2(0,1)
	_major_text.modulate = Color(1,1,1,1)
	_color_overlay.color = Color(1,1,1,0)
	_enable_shine(false)

