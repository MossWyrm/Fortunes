extends Panel
class_name buff_display

signal initialization_complete

var label: Label
var animator: AnimationPlayer
var sprite: Sprite2D
var highlight: ColorRect
var _tooltip_card: Card
var hold_timer: Timer
const HOLD_DURATION := 0.6

func _ready() -> void:
	label = $Label
	animator = $AnimationPlayer
	sprite = $Sprite2D
	highlight = $MASK/ColorRect
	hold_timer = Timer.new()
	hold_timer.wait_time = HOLD_DURATION
	hold_timer.one_shot = true
	add_child(hold_timer)
	hold_timer.connect("timeout", Callable(self, "_on_hold_timer_timeout"))
	
	# Wait one frame to ensure everything is properly initialized
	await get_tree().process_frame
	# Signal that initialization is complete
	initialization_complete.emit()

func set_texture(texture: Texture2D) -> void:
	if texture != sprite.texture:
		sprite.texture = texture

func set_text(value: String) -> void:
	if value == "":
		label.hide()
	elif value != label.text:
		label.text = value
		label.show()
		play_anim()

func play_anim() -> void:
	animator.play("icon_updating")

func hide_anim() -> void:
	animator.play("fade_out")
	await animator.animation_finished

func set_panel_color(panel_color: Color = Color.WHITE) -> void:
	if panel_color == Color.WHITE:
		highlight.hide()
	else:
		highlight.color = panel_color
		highlight.show()

func set_tooltip_card(card: Card) -> void:
	_tooltip_card = card

func show_tooltip() -> void:
	if _tooltip_card and ValidationUtils.has_event_bus():
		EventBus.emit_tooltip_requested(_tooltip_card, DataStructures.GameLayer.DECK)

func _on_press(_event: InputEvent):
	if Input.is_action_just_pressed("ui_click"):
		hold_timer.start()
	elif Input.is_action_just_released("ui_click"):
		hold_timer.stop()

func _on_hold_timer_timeout():
	show_tooltip()
		