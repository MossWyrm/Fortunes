extends Node

var auto_draw_enabled: bool = false
var auto_draw_button: Button
@onready var auto_draw_button_active_overlay: Node = $/root/Main/DisplayMaster/Navigation/AutoDrawButton/Active
@onready var draw_card_button: Button = $/root/Main/DisplayMaster/Navigation/MarginContainer/HBoxNav/DrawCardButton

var auto_draw_timer: float = 0

func _ready() -> void:
	auto_draw_button = $/root/Main/DisplayMaster/Navigation/AutoDrawButton
	auto_draw_button.pressed.connect(toggle_auto_draw)
	
func _process(delta: float) -> void:
	if GameManager.game_state.stats.pack_auto_draw && !auto_draw_button.is_visible():
		auto_draw_button.show()
	auto_draw(delta)
	
func toggle_auto_draw() -> void:
	auto_draw_enabled = !auto_draw_enabled
	auto_draw_button_active_overlay.visible = auto_draw_enabled
	draw_card_button.force_disable_button(auto_draw_enabled)
	
func auto_draw(delta: float) -> void:
	if !auto_draw_enabled:
		auto_draw_timer = 0
		return
	auto_draw_timer += delta
	if auto_draw_timer >= GameManager.game_state.stats.pack_auto_draw_speed:
		auto_draw_timer = 0
		GameManager.event_bus.emit_draw_card()
		await get_tree().create_timer(GameManager.game_state.stats.pack_auto_draw_speed/2).timeout	
		GameManager.event_bus.emit_clear_card()
		