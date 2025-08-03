extends Panel
class_name buff_display

var label: Label
var animator: AnimationPlayer
var sprite: Sprite2D
var highlight: ColorRect
var _tooltip: DataStructures.TooltipData
var holding: bool = false
var hold_timer: float = 0.0
var hold_duration: float = 0.6

func _ready() -> void:
	init()
	
	
func _process(delta: float) -> void:
	if holding:
		hold_timer += delta
		if hold_timer >= hold_duration:
			holding = false
			hold_timer = 0
			show_tooltip()
			
func init() -> void:
	label = $Label
	animator = $AnimationPlayer
	sprite = $Sprite2D
	highlight = $MASK/ColorRect
	
func set_texture(texture: Texture2D) -> void:
	if texture != sprite.texture:
		sprite.texture = texture
	
func set_text(value: String) -> void:
	if value != label.text:
		label.text = value
		label.show()
		play_anim()
	elif value == "":
		label.hide()
		
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

func set_tooltip_data(tooltip: DataStructures.TooltipData) -> void:
	_tooltip = tooltip
	
func show_tooltip() -> void:
	GameManager.event_bus.emit_tooltip_requested(_tooltip)
	
func _on_press(_event:InputEvent):
	if Input.is_action_just_pressed("ui_click"):
		holding = true
	if Input.is_action_just_released("ui_click"):
		holding = false
		hold_timer = 0
		