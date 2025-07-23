extends Node

@export var default_card_texture: Texture

@onready var card_display_title : Label = $Scroll/MarginContainer/card_text
@onready var card_major_display_title : Label = $MajorTextDisplay/VBoxContainer/card_text
@onready var card_display_background : TextureRect = $CardFront
@onready var card_display_overlay: TextureRect = $CardFront/FaceImage
signal anim_finished
var animator : AnimationPlayer
var sparkle_anim: AnimationPlayer
var draw_anim_finished: bool = false:
	set(value):
		draw_anim_finished = value
		anim_finished.emit()
var current_card: Card
var flipped_state: bool
var holding: bool
var hold_timer: float
var hold_duration: float = 0.8
var clearing_major: bool = false
var major_flipped: bool = false
var block_remove: bool = false
var signal_recieved: bool = false
var skip_card: bool = false

func _process(delta: float) -> void:
	if holding:
		hold_timer += delta
		if hold_timer >= hold_duration:
			holding = false
			hold_timer = 0
			Events.emit_card_tooltip(current_card)

func _ready():
	Events.selected_card.connect(update_card_display)
	Events.clear_card.connect(clear_card)
	Events.card_animation_major.connect(clear_major)
	Events.skip_choice.connect(card_skip)
	card_display_title.text = "~"
	card_major_display_title.text = "~"
	animator = $CardFlipAnimations
	sparkle_anim = $Sparkling

func update_card_display(card: Card, flipped: bool):
	flipped_state = flipped
	set_card_image(card)
	
	if card.card_id_num >= 500:
		block_remove = true
		card_major_display_title.text = card.get_title()
		play_major_anim()
	else:
		card_display_title.text = card.get_title()
		play_flip_animation(flipped)
	current_card = card

func play_flip_animation(flipped) -> void:
	sparkle_anim.stop()
	if flipped:
		card_display_background.rotation = 3.14
		animator.play("CardDrawBad")
		card_display_title.label_settings.font_color = Color(0.712, 0.127, 0.128)
	else:
		card_display_background.rotation = 0
		animator.play("CardDrawGood")
		card_display_title.label_settings.font_color = Color(0.0,0.0,0.0)

func play_major_anim() -> void:
	card_display_background.rotation = 0
	animator.play("MajorDraw")
	sparkle_anim.play("sparkle")
	
func finish_draw_anim():
	draw_anim_finished = true
	clearing_major = false
	
func clear_major(_flipped: bool) -> void:
	signal_recieved = true
	
func card_skip(skipping: bool) -> void:
	skip_card = skipping
	block_remove = false
	clear_card()

func clear_card() -> void:
	if current_card == null || (current_card.card_id_num >= 500 && (block_remove && !signal_recieved)):
		return
	block_remove = false
	signal_recieved = false
	if draw_anim_finished && skip_card:
		var color: Color = Color.WHITE
		card_display_overlay.material.set("shader_parameter/burn_color", color)
		card_display_background.material.set("shader_parameter/burn_color", color)
		animator.play("SkipCard")
		draw_anim_finished = false
		skip_card = false
	elif draw_anim_finished:
		var color = ID.PanelColor.GOOD if !flipped_state else ID.PanelColor.BAD
		card_display_overlay.material.set("shader_parameter/burn_color", color)
		card_display_background.material.set("shader_parameter/burn_color", color)
		animator.play("ReturnCard")
		draw_anim_finished = false
		skip_card = false

func card_cleared() -> void:
	Events.emit_card_draw_animation_finish()

func set_card_image(card: Card) -> void:
	var dict: Dictionary = ResourceAutoload.get_card_texture(card)
	if dict.size() == 0:
		card_display_background.texture = default_card_texture
		return
	var background: Texture2D = dict["background"]
	var overlay: Texture2D = dict["overlay"]
	card_display_background.texture = background if not null else null
	card_display_overlay.texture = overlay if not null else null
	card_display_overlay.material.set("shader_parameter/atlas_size", overlay.atlas.get_size())
	
func press_and_hold(_event: InputEvent):
	if Input.is_action_just_pressed("ui_click"):
		holding = true
	if Input.is_action_just_released("ui_click"):
		if hold_timer < hold_duration && !Stats.pause_drawing:
			clear_card()
		holding = false
		hold_timer = 0