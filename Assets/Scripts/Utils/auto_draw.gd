extends Node
class_name AutoDraw
## Auto-draw system for automated card drawing
##
## Manages automatic card drawing functionality with configurable timing.
## Integrates with the EventBus system and provides visual feedback through UI.

#region Node References
@onready var auto_draw_button_active_overlay: Node = $/root/Main/DisplayMaster/Navigation/AutoDrawButton/Active
@onready var draw_card_button: Button = $/root/Main/DisplayMaster/Navigation/MarginContainer/HBoxNav/DrawCardButton
#endregion

#region Properties
var auto_draw_enabled: bool = false
var auto_draw_button: Button
var auto_draw_timer: float = 0.0
#endregion

#region Initialization
func _ready() -> void:
	_setup_auto_draw_button()
	_connect_signals()

# Setup auto draw button reference
func _setup_auto_draw_button() -> void:
	auto_draw_button = $/root/Main/DisplayMaster/Navigation/AutoDrawButton
	if auto_draw_button:
		SignalManager.safe_connect(auto_draw_button.pressed, _on_auto_draw_toggled)
	else:
		push_error("AutoDraw: Could not find auto draw button")

# Connect to EventBus signals safely
func _connect_signals() -> void:
	SignalManager.connect_to_event_bus("game_reset", _on_game_reset)
	SignalManager.connect_to_event_bus("game_paused", _on_game_paused)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect all signals safely
func _disconnect_signals() -> void:
	if auto_draw_button:
		SignalManager.safe_disconnect(auto_draw_button.pressed, _on_auto_draw_toggled)
	
	SignalManager.disconnect_from_event_bus("game_reset", _on_game_reset)
	SignalManager.disconnect_from_event_bus("game_paused", _on_game_paused)
#endregion

#endregion

#region Update Loop
func _process(delta: float) -> void:
	_update_button_visibility()
	_process_auto_draw(delta)

# Update auto draw button visibility based on unlock status
func _update_button_visibility() -> void:
	if not auto_draw_button:
		return
	
	var should_show = _is_auto_draw_unlocked() and not auto_draw_button.is_visible()
	if should_show:
		auto_draw_button.show()

# Check if auto draw feature is unlocked
func _is_auto_draw_unlocked() -> bool:
	if ValidationUtils.has_game_state():
		return GameManager.game_state.stats.pack_auto_draw
	return false
#endregion

#region Auto Draw Control
# Toggle auto draw on/off
func _on_auto_draw_toggled() -> void:
	auto_draw_enabled = not auto_draw_enabled
	_update_visual_feedback()
	_update_draw_button_state()

# Update visual feedback for auto draw state
func _update_visual_feedback() -> void:
	if auto_draw_button_active_overlay:
		auto_draw_button_active_overlay.visible = auto_draw_enabled

# Update draw card button state based on auto draw
func _update_draw_button_state() -> void:
	if draw_card_button and draw_card_button.has_method("force_disable_button"):
		draw_card_button.force_disable_button(auto_draw_enabled)
#endregion

#region Auto Draw Processing
# Process auto draw timing and execution
func _process_auto_draw(delta: float) -> void:
	if not auto_draw_enabled:
		auto_draw_timer = 0.0
		return
	
	auto_draw_timer += delta
	
	var auto_draw_speed = _get_auto_draw_speed()
	if auto_draw_timer >= auto_draw_speed:
		await _execute_auto_draw_cycle(auto_draw_speed)

# Execute a complete auto draw cycle
func _execute_auto_draw_cycle(auto_draw_speed: float) -> void:
	auto_draw_timer = 0.0
	
	# Draw card
	_emit_draw_card()
	
	# Wait for half the speed duration
	await get_tree().create_timer(auto_draw_speed / 2.0).timeout
	
	# Clear card
	_emit_clear_card()

# Get current auto draw speed from game state
func _get_auto_draw_speed() -> float:
	if ValidationUtils.has_game_state():
		return GameManager.game_state.stats.pack_auto_draw_speed
	return GameConstants.DEFAULT_ANIMATION_SPEED  # Default fallback speed

# Emit draw card event through EventBus
func _emit_draw_card() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.card_draw_requested.emit()

# Emit clear card event through EventBus
func _emit_clear_card() -> void:
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.card_clear_requested.emit()
#endregion

#region Event Handlers
# Handle game reset events
func _on_game_reset(_reset_type: DataStructures.GameLayer) -> void:
	auto_draw_enabled = false
	_update_visual_feedback()

# Handle game pause events
func _on_game_paused(paused: bool) -> void:
	if paused:
		auto_draw_timer = 0.0
#endregion