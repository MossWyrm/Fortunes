extends Control
class_name CardSelectDisplayBox

	
@export var locked: CardSelectDisplayBoxLocked
@export var unlocked: CardSelectDisplayBoxUnlocked

var stored_card: Card
var stop_add
var stop_remove

var holding: bool = false
var hold_timer: float = 0.0
var hold_delay: float = 1.0

func _ready() -> void:
	unlocked.add_card_button.pressed.connect(add_card_to_deck)
	unlocked.remove_card_button.pressed.connect(remove_card_from_deck)
	
func _process(delta: float) -> void:
	if holding:
		_check_for_purchase(delta)
	
func update_display(card: Card, addable: bool, removable: bool, currently_in_deck: int = -1) -> void:
	if card.unlocked:
		locked.hide()
		unlocked.display(card,currently_in_deck)
		unlocked.show()
	else:
		unlocked.hide()
		locked.display(card)
		locked.show()
	stored_card = card
	stop_add_card(!addable)
	stop_remove_card(!removable)

func stop_add_card(val: bool) -> void:
	unlocked.stop_add(val)
	stop_add = val

func stop_remove_card(val: bool) -> void:
	unlocked.stop_remove(val)
	stop_remove = val

func remove_card_from_deck() -> void:
	if stop_remove: return
	Events.emit_remove_card_from_deck(stored_card)
	print("removed card")

func add_card_to_deck() -> void:
	if stop_add: return
	Events.emit_add_card_to_deck(stored_card)
	print("Added card")

func buy_card() -> void:
	Events.emit_unlock_card(stored_card)
	Events.emit_update_currency(-stored_card.unlock_cost)
	holding = false
	hold_timer = 0

func _check_for_purchase(delta: float) -> void:
	hold_timer += delta
	if !locked.unlock_button.is_disabled():
		if hold_timer >= hold_delay:
			buy_card()
			locked.set_slider_percent(0.0)
		else:
			var percent = hold_timer / hold_delay
			locked.set_slider_percent(percent if percent < 1.0 else 1.0)

func _on_card_face_gui_input(_event:InputEvent) -> void:
	if Input.is_action_just_released("ui_click"):
		Events.emit_card_tooltip(stored_card)

func _on_button_gui_input(_event:InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		holding = true
	if Input.is_action_just_released("ui_click"):
		if locked.unlock_button.is_disabled() || hold_timer < (hold_delay / 2):
			Events.emit_card_tooltip(stored_card)
		locked.set_slider_percent(0.0)
		holding = false
		hold_timer = 0