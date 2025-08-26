extends Control
class_name AddableCard
## Animated card for add/remove visual feedback
##
## Provides visual animation for cards being added to or removed from the deck.
## Handles shader effects, scaling, and movement animations with different styles
## for add vs remove operations.

#region Node References
@onready var background: TextureRect = $Background
@onready var overlay: TextureRect = $Background/Overlay
#endregion

#region Enums
enum AnimationType {
	ADDABLE,
	REMOVABLE
}
#endregion

#region Properties
var animation_type: AnimationType
var mid_point: Vector2
var fade_duration: float = 0.0
var movement_duration: float = 0.0
#endregion

#region Configuration
# Set animation timing parameters
func set_speeds(move_dur: float, fade_dur: float) -> void:
	movement_duration = move_dur
	fade_duration = fade_dur
#endregion

#region Card Setup
# Configure card for add animation
func create_addable(card: Card) -> void:
	if not card:
		push_error("AddableCard: Cannot create addable with null card")
		return
	
	_setup_card_visuals(card)
	_configure_addable_appearance()
	animation_type = AnimationType.ADDABLE

# Configure card for remove animation
func create_removable(card: Card) -> void:
	if not card:
		push_error("AddableCard: Cannot create removable with null card")
		return
	
	_setup_card_visuals(card)
	_configure_removable_appearance()
	animation_type = AnimationType.REMOVABLE

# Setup basic card visuals and textures
func _setup_card_visuals(card: Card) -> void:
	var textures = PreloadedResources.get_card_texture(card)
	
	if background:
		background.texture = textures["background"]
	
	if overlay:
		overlay.texture = textures["overlay"]
		if overlay.material and textures["overlay"].atlas:
			overlay.material.set("shader_parameter/atlas_size", textures["overlay"].atlas.get_size())

# Configure appearance for add animation
func _configure_addable_appearance() -> void:
	z_index = 3
	scale = GameConstants.CARD_SCALE_SMALL
	
	_set_burn_parameters(GameConstants.BURN_FADE_START, DataStructures.PanelColor.GOOD)

# Configure appearance for remove animation
func _configure_removable_appearance() -> void:
	z_index = 2
	scale = Vector2(0.3, 0.3)
	
	_set_burn_parameters(0.0, DataStructures.PanelColor.BAD)

# Set shader burn parameters for both background and overlay
func _set_burn_parameters(burn_amount: float, burn_color: Color) -> void:
	if background and background.material:
		background.material.set("shader_parameter/burn_amount", burn_amount)
		background.material.set("shader_parameter/burn_color", burn_color)
	
	if overlay and overlay.material:
		overlay.material.set("shader_parameter/burn_amount", burn_amount)
		overlay.material.set("shader_parameter/burn_color", burn_color)
#endregion
#endregion

#region Animation Control
# Start the animation sequence
func play(mid: Vector2, center: Vector2, random: Vector2 = Vector2.ZERO) -> void:
	show()
	mid_point = mid
	
	match animation_type:
		AnimationType.ADDABLE:
			global_position = random
			await _play_add_sequence(center)
		AnimationType.REMOVABLE:
			global_position = center
			await _play_remove_sequence(random)

# Play the add card animation sequence
func _play_add_sequence(center_point: Vector2) -> void:
	# Phase 1: Fade in from burn effect
	await _animate_burn_fade(GameConstants.BURN_FADE_START, GameConstants.BURN_FADE_END)
	
	# Phase 2: Move to middle and scale up
	await _animate_to_midpoint()
	
	# Phase 3: Move to center and final scale
	await _animate_to_center(center_point)
	
	queue_free()

# Play the remove card animation sequence
func _play_remove_sequence(random_point: Vector2) -> void:
	# Phase 1: Move to middle and scale up
	await _animate_to_midpoint()
	
	# Phase 2: Move to random point and scale down
	await _animate_to_random_point(random_point)
	
	# Phase 3: Fade out with burn effect
	await _animate_burn_fade(GameConstants.BURN_FADE_END, GameConstants.BURN_FADE_START)
	
	queue_free()
#endregion

#region Animation Phases
# Animate burn effect fade in/out
func _animate_burn_fade(from_burn: float, to_burn: float) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	
	if background and background.material:
		tween.tween_method(
			func(x): background.material.set("shader_parameter/burn_amount", x),
			from_burn, to_burn, fade_duration
		)
	
	if overlay and overlay.material:
		tween.parallel().tween_method(
			func(x): overlay.material.set("shader_parameter/burn_amount", x),
			from_burn, to_burn, fade_duration
		)
	
	await tween.finished

# Animate movement to midpoint
func _animate_to_midpoint() -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), half_movement)
	tween.parallel().tween_property(self, "global_position", mid_point, half_movement)
	
	await tween.finished

# Animate movement to center point (add animation)
func _animate_to_center(center_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	
	tween.tween_property(self, "z_index", 2, 0)
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), half_movement)
	tween.parallel().tween_property(self, "global_position", center_point, half_movement)
	
	await tween.finished

# Animate movement to random point (remove animation)
func _animate_to_random_point(random_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	
	tween.tween_property(self, "z_index", 3, 0)
	tween.parallel().tween_property(self, "scale", Vector2(0.6, 0.6), half_movement)
	tween.parallel().tween_property(self, "global_position", random_point, half_movement)
	
	await tween.finished
#endregion