extends Control
class_name CardSelectDisplayBox

@export var card_image: TextureRect
@export var card_title: Label
@export var card_cost: Label
@export var current_count_display: Label
@export var add_card_button: TextureButton
@export var remove_card_button: TextureButton
@export var buy_card_button: TextureButton
@export var deck_mod_buttons: Node
var stored_card: Card
var stop_add
var stop_remove

func _ready():
	add_card_button.pressed.connect(add_card_to_deck)
	remove_card_button.pressed.connect(remove_card_from_deck)
	buy_card_button.pressed.connect(buy_card)

func update_display(card: Card, addable: bool, removable: bool, currently_in_deck: int = -1):
	card_title.text = card._get_title()
	stored_card = card
	if card.card_image == null:
		card_image.texture = load("res://Assets/Sprites/CardBack.png")
	else:
		card_image.texture = card.card_image
		

	if card.unlocked == false:
		deck_mod_buttons.visible = false
		card_cost.text = "Unlock: "+str(card.unlock_cost)
		return
	else:
		deck_mod_buttons.visible = true
		buy_card_button.visible = false
		card_cost.visible = false

	current_count_display.text = str(currently_in_deck)
	

	stop_add_card(!addable)
	stop_remove_card(!removable)

func remove_card_from_deck():
	if stop_remove:
		pass
	Events.emit_remove_card_from_deck(stored_card)
	print("removed card")

func add_card_to_deck() -> void:
	if stop_add:
		pass
	Events.emit_add_card_to_deck(stored_card)
	print("Added card")

func stop_add_card(val: bool):
	add_card_button.disabled = val
	stop_add = val

func stop_remove_card(val: bool):
	remove_card_button.disabled = val
	stop_remove = val


func set_as_in_deck(_deck_status: bool):
	pass

func set_as_buyable():
	pass

func buy_card():
	if Stats.current_currency >= stored_card.unlock_cost:
		Events.emit_unlock_card(stored_card)
	else:
		pass
