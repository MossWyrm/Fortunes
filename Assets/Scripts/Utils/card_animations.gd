extends Control
class_name card_animations
## Card add/remove animation controller
##
## Manages visual animations for cards being added to or removed from the deck.
## Handles timing, positioning, and visual feedback for card transitions.

@export_category("Animation Settings")
@export var delay_between_cards: float = 0.2
@export var moving_duration: float = 0.3
@export var fade_duration: float = 0.6

var animatable_obj: PackedScene = preload("res://Assets/Scenes/addable_card.tscn")
@onready var target_pos: Marker2D = $MidPoint
@onready var center: Marker2D = $CenterPoint

var cards_to_add: Array[Card] = []
var cards_to_remove: Array[Card] = []
var add_timer: float = 0.0
var remove_timer: float = 0.0

#region Initialization
func _ready() -> void:
	EventBus.request_deck_change_animation.connect(_on_request_deck_change_animation)
#endregion

#region Public Interface
# Queue a card for add animation
func add_card(card: Card) -> void:
	if not card:
		DebugManager.print_card_animations("CardAnimations: Attempted to add null card", DebugManager.DebugLevel.WARNING)
		return
	cards_to_add.append(card)

# Queue a card for remove animation
func remove_card(card: Card) -> void:
	if not card:
		DebugManager.print_card_animations("CardAnimations: Attempted to remove null card", DebugManager.DebugLevel.WARNING)
		return
	cards_to_remove.append(card)
#endregion

#region Update Loop
func _process(delta: float) -> void:
	_update_timers(delta)
	_process_animation_queues()

# Update animation timers
func _update_timers(delta: float) -> void:
	add_timer = max(0.0, add_timer - delta)
	remove_timer = max(0.0, remove_timer - delta)

# Process queued animations when timers allow
func _process_animation_queues() -> void:
	if not cards_to_add.is_empty() and add_timer <= 0.0:
		_play_add_animation()
	
	if not cards_to_remove.is_empty() and remove_timer <= 0.0:
		_play_remove_animation()
#endregion

#region Animation Creation
# Create and play add card animation
func _play_add_animation() -> void:
	add_timer = delay_between_cards
	var card: Card = cards_to_add.pop_front()
	
	if not card:
		DebugManager.print_card_animations("CardAnimations: Card became null during add animation", DebugManager.DebugLevel.WARNING)
		return
	
	var addable: AddableCard = _create_animatable_object()
	addable.create_addable(card)
	addable.play(target_pos.global_position, center.global_position, _get_random_spawn_point())

# Create and play remove card animation
func _play_remove_animation() -> void:
	remove_timer = delay_between_cards
	var card: Card = cards_to_remove.pop_front()
	
	if not card:
		DebugManager.print_card_animations("CardAnimations: Card became null during remove animation", DebugManager.DebugLevel.WARNING)
		return
	
	var addable: AddableCard = _create_animatable_object()
	addable.create_removable(card)
	addable.play(target_pos.global_position, center.global_position, _get_random_spawn_point())

# Create a new animatable card object
func _create_animatable_object() -> AddableCard:
	var obj: AddableCard = animatable_obj.instantiate()
	add_child(obj)
	obj.set_speeds(moving_duration, fade_duration)
	return obj

# Generate a random point around the center for animation variety
func _get_random_spawn_point() -> Vector2:
	var spawn_point: Vector2 = center.global_position
	spawn_point.x += GameConstants.get_random_spawn_variance()
	spawn_point.y += randf_range(-175, 175)
	return spawn_point
#endregion

#region event handlers
# Handle requests to animate card additions/removals
func _on_request_deck_change_animation(operation: DataStructures.DeckOperation, card: Card) -> void:
	match operation:
		DataStructures.DeckOperation.ADD:
			add_card(card)
		DataStructures.DeckOperation.REMOVE:
			remove_card(card)
		_:
			DebugManager.print_card_animations("CardAnimations: Unsupported operation for deck change animation: %s" % operation)
#endregion