extends Control
class_name AddRemove

@export_category("Variables")
@export var delay_between_cards: float = 0.2
@export var moving_duration: float = 0.3
@export var fade_duration: float = 0.6

var animatable_obj: PackedScene = preload("res://Assets/Scenes/addable_card.tscn")
@onready var target_pos: Marker2D = $TargetPoint
@onready var center: Marker2D    = $StartPoint

var cards_to_add: Array[Card]    = []
var cards_to_remove: Array[Card] = []

var add_timer: float = 0
var remove_timer: float = 0

func add_card(card: Card) -> void:
	if card == null:
		return
	cards_to_add.append(card)
	
func remove_card(card:Card) -> void:
	if card == null:
		return
	cards_to_remove.append(card)

func _process(delta: float) -> void:
	add_timer -= delta if add_timer > 0 else 0.0
	remove_timer -= delta if remove_timer > 0 else 0.0
	if !cards_to_add.is_empty() && add_timer <= 0.0:
		add_card_anim()
	if !cards_to_remove.is_empty() && remove_timer <= 0.0:
		remove_card_anim()
		
func add_card_anim() -> void:
	add_timer = delay_between_cards
	var card: Card = cards_to_add.pop_front()
	if card == null:
		return
	var addable: AddableCard = get_animatable_object()
	addable.create_addable(card)
	addable.play(target_pos.global_position, center.global_position, get_random_point())
	
func remove_card_anim() -> void:
	remove_timer = delay_between_cards
	var card: Card = cards_to_remove.pop_front()
	if card == null:
		return
	var addable: AddableCard = get_animatable_object()
	addable.create_removable(card)
	addable.play(target_pos.global_position, center.global_position, get_random_point())
	
	
func get_animatable_object() -> AddableCard:
	var obj: AddableCard = animatable_obj.instantiate()
	add_child(obj)
	obj.set_speeds(moving_duration, fade_duration)
	return obj
	
func get_random_point() -> Vector2:
	var vec: Vector2 = center.global_position
	vec.x += randf_range(-100,100)
	vec.y += randf_range(-175, 175)
	return vec