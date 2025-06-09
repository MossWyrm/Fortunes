extends Node

@export var default_card_texture: Texture

@onready var card_display_title : Label = $Scroll/MarginContainer/card_text
@onready var card_display_background : TextureRect = $CardFront
@onready var card_display_overlay: TextureRect = $CardFront/FaceImage

var animator : AnimationPlayer
var draw_anim_finished: bool = false
var current_card: Card
var holding: bool
var hold_timer: float
var hold_duration: float = 0.8

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
	card_display_title.text = "~"
	animator = $CardFlipAnimations

func update_card_display(card: Card, flipped: bool):
	card_display_title.text = card.get_title()
	set_card_image(card)
	if card.card_id_num >= 500:
		play_major_anim()
	else:
		play_flip_animation(flipped)
	current_card = card

func play_flip_animation(flipped) -> void:
	if flipped:
		card_display_background.rotation = 3.14
		card_display_title.rotation = 3.14
		animator.play("CardDrawBad")
		card_display_title.label_settings.font_color = Color(0.712, 0.127, 0.128)
	else:
		card_display_background.rotation = 0
		card_display_title.rotation = 0
		animator.play("CardDrawGood")
		card_display_title.label_settings.font_color = Color(0.0,0.0,0.0)

func play_major_anim() -> void:
	card_display_background.rotation = 0
	card_display_title.rotation = 0
	animator.play("MajorDraw")
	card_display_title.label_settings.font_color = ID.SuitColor["GOOD"]
	
func finish_draw_anim():
	draw_anim_finished = true
	
func clear_major(flipped: bool) -> void:
	draw_anim_finished = false
	if flipped:
		animator.play("MajorBad")
	else:
		animator.play("MajorGood")
		

func clear_card() -> void:
	if current_card.card_id_num >= 500:
		return
	if draw_anim_finished:
		animator.play("ReturnCard")
		draw_anim_finished = false

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
	
func press_and_hold(_event: InputEvent):
	if Input.is_action_just_pressed("ui_click"):
		holding = true
	if Input.is_action_just_released("ui_click"):
		if hold_timer < hold_duration && !Stats.pause_drawing:
			clear_card()
		holding = false
		hold_timer = 0