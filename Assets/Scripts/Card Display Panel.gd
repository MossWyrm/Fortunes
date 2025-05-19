extends Node

@export var card_display_title : Label
@export var card_display_image : TextureRect
@export var default_card_texture: Texture
var animator : AnimationPlayer
var draw_anim_finished = false

func _ready():
	Events.selected_card.connect(update_card_display)
	Events.clear_card.connect(clear_card)
	card_display_title.text = "~"
	animator = $CardFlipAnimations

func update_card_display(card: Card, flipped: bool):
	card_display_title.text = card._get_title()
	set_card_image(card)
	if flipped:
		card_display_image.rotation = 3.14
		card_display_title.rotation = 3.14
		animator.play("CardDrawBad")
		print(card._get_title() + " FLIPPED")
	else:
		card_display_image.rotation = 0
		card_display_title.rotation = 0
		print(card._get_title())
		animator.play("CardDrawGood")

func finish_draw_anim():
	draw_anim_finished = true

func clear_card():
	if draw_anim_finished:
		animator.play("ReturnCard")
		draw_anim_finished = false

func card_cleared() -> void:
	Events.emit_card_draw_animation_finish()

func set_card_image(card: Card):
	var output_texture = null
	if card.card_image == null:
		output_texture = default_card_texture
	else:
		output_texture = card.card_image
	card_display_image.texture = output_texture