extends Control
class_name AddableCard

@onready var background: TextureRect = $Background
@onready var overlay: TextureRect = $Background/Overlay
enum anim_type {ADDABLE, REMOVABLE}

var anim: anim_type

var mid_point: Vector2
var fade: float = 0.0
var movement: float = 0.0

func set_speeds(move_dur: float, fade_dur: float) -> void:
	fade = fade_dur
	movement = move_dur

func create_addable(card: Card) -> void:
	if card == null:
		return
	_set_textures(card)
	z_index = 3
	background.material.set("shader_parameter/burn_amount", 1)
	overlay.material.set("shader_parameter/burn_amount", 1)
	background.material.set("shader_parameter/burn_color", ID.PanelColor.GOOD)
	overlay.material.set("shader_parameter/burn_color", ID.PanelColor.GOOD)
	scale = Vector2(0.5,0.5)
	anim = anim_type.ADDABLE
	
func create_removable(card: Card) -> void:
	if card == null:
		return
	_set_textures(card)
	z_index = 2
	background.material.set("shader_parameter/burn_amount", 0)
	overlay.material.set("shader_parameter/burn_amount", 0)
	background.material.set("shader_parameter/burn_color", ID.PanelColor.BAD)
	overlay.material.set("shader_parameter/burn_color", ID.PanelColor.BAD)
	scale = Vector2(0.3,0.3)
	anim = anim_type.REMOVABLE
	
func _set_textures(card: Card) -> void:
	var textures = ResourceAutoload.get_card_texture(card)
	background.texture = textures["background"]
	overlay.texture = textures["overlay"]
	overlay.material.set("shader_parameter/atlas_size",textures["overlay"].atlas.get_size())
	
func play(mid: Vector2, center: Vector2, random: Vector2 = Vector2.ZERO) -> void:
	show()
	mid_point = mid
	match anim:
		anim_type.ADDABLE:
			global_position = random
			_play_add(center)
		anim_type.REMOVABLE:
			global_position = center
			_play_remove(random)
	
func _play_add(center_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(x): background.material.set("shader_parameter/burn_amount",x),1.0,0.0,fade)
	tween.parallel().tween_method(func(x): overlay.material.set("shader_parameter/burn_amount",x),1.0,0.0,fade)
	await tween.finished
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale", Vector2(0.7,0.7), movement/2.0)
	tween.parallel().tween_property(self,"global_position",mid_point, movement/2.0)
	await tween.finished
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"z_index",2,0)
	tween.parallel().tween_property(self,"scale", Vector2(0.9,0.9), movement/2.0)
	tween.parallel().tween_property(self,"global_position", center_point, movement/2.0)
	await tween.finished
	queue_free()
	
func _play_remove(random_point: Vector2) -> void:
	var tween: Tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"scale", Vector2(0.9,0.9), movement/2.0)
	tween.parallel().tween_property(self,"global_position",mid_point, movement/2.0)
	await tween.finished
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"z_index",3,0)
	tween.parallel().tween_property(self,"scale", Vector2(0.6,0.6), movement/2.0)
	tween.parallel().tween_property(self,"global_position", random_point, movement/2.0)
	await tween.finished
	tween = get_tree().create_tween().bind_node(self).set_trans(Tween.TRANS_LINEAR)
	tween.tween_method(func(x): background.material.set("shader_parameter/burn_amount",x),0.0,1.0,fade)
	tween.parallel().tween_method(func(x): overlay.material.set("shader_parameter/burn_amount",x),0.0,1.0,fade)
	await tween.finished
	queue_free()