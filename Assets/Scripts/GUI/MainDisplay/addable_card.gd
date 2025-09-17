extends Control
class_name AddableCard

## Addable/Removable card animation component
## Handles the visual representation and animation of cards being added to or removed from the deck.

@onready var background: TextureRect = $Background
@onready var overlay: TextureRect = $Background/Overlay

enum AnimationType {
	ADDABLE,
	REMOVABLE
}

var animation_type: AnimationType
var mid_point: Vector2
var fade_duration: float = 0.0
var movement_duration: float = 0.0

func set_speeds(move_dur: float, fade_dur: float) -> void:
	movement_duration = move_dur
	fade_duration = fade_dur

#region Public Interfaces
func create_addable(card: Card) -> void:
	if not card:
		DebugManager.print_card_management("AddableCard: Cannot create addable with null card", DebugManager.DebugLevel.ERROR)
		return
	
	_setup_card_visuals(card)
	_configure_addable_appearance()
	animation_type = AnimationType.ADDABLE

func create_removable(card: Card) -> void:
	if not card:
		DebugManager.print_card_management("AddableCard: Cannot create removable with null card", DebugManager.DebugLevel.ERROR)
		return
	
	_setup_card_visuals(card)
	_configure_removable_appearance()
	animation_type = AnimationType.REMOVABLE

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
#endregion

#region Internal Setup
func _setup_card_visuals(card: Card) -> void:
	var textures = PreloadedResources.get_card_texture(card)
	
	if background:
		background.texture = textures["background"]
	
	if overlay:
		overlay.texture = textures["overlay"]
		if overlay.material and textures["overlay"].atlas:
			overlay.material.set("shader_parameter/atlas_size", textures["overlay"].atlas.get_size())

func _configure_addable_appearance() -> void:
	z_index = 0
	scale = GameConstants.CARD_SCALE_SMALL
	
	_set_burn_parameters(GameConstants.BURN_FADE_START, DataStructures.core_color.GOOD)

func _configure_removable_appearance() -> void:
	z_index = -1
	scale = Vector2(0.3, 0.3)
	
	_set_burn_parameters(0.0, DataStructures.core_color.BAD)

func _set_burn_parameters(burn_amount: float, burn_color: Color) -> void:
	if background and background.material:
		background.material.set("shader_parameter/burn_amount", burn_amount)
		background.material.set("shader_parameter/burn_color", burn_color)
	
	if overlay and overlay.material:
		overlay.material.set("shader_parameter/burn_amount", burn_amount)
		overlay.material.set("shader_parameter/burn_color", burn_color)
#endregion

#region Animation Sequences
func _play_add_sequence(center_point: Vector2) -> void:
	await _animate_burn_fade(GameConstants.BURN_FADE_START, GameConstants.BURN_FADE_END)
	await _animate_to_midpoint()
	await _animate_to_center(center_point)
	queue_free()

func _play_remove_sequence(random_point: Vector2) -> void:
	await _animate_to_midpoint()
	await _animate_to_random_point(random_point)
	await _animate_burn_fade(GameConstants.BURN_FADE_END, GameConstants.BURN_FADE_START)
	queue_free()

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

func _animate_to_midpoint() -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	
	tween.tween_property(self, "scale", Vector2(0.7, 0.7), half_movement)
	tween.parallel().tween_property(self, "global_position", mid_point, half_movement)
	
	await tween.finished

func _animate_to_center(center_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	z_index = -1
	tween.parallel().tween_property(self, "scale", Vector2(0.9, 0.9), half_movement)
	tween.parallel().tween_property(self, "global_position", center_point, half_movement)
	
	await tween.finished

func _animate_to_random_point(random_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	var half_movement = movement_duration / 2.0
	
	z_index = 0
	tween.parallel().tween_property(self, "scale", Vector2(0.6, 0.6), half_movement)
	tween.parallel().tween_property(self, "global_position", random_point, half_movement)
	
	await tween.finished
#endregion