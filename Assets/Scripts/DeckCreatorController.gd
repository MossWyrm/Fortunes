extends Node

@export var cups_panels_display : CardSelectBoxList
@export var wands_panels_display : CardSelectBoxList
@export var pentacles_panels_display : CardSelectBoxList
@export var swords_panels_display : CardSelectBoxList
@export var majors_panels_display: CardSelectBoxList
@export var deck_stats_display: DeckStats

@onready var panel_displays = [cups_panels_display, 
		wands_panels_display, 
		pentacles_panels_display, 
		swords_panels_display, 
		majors_panels_display]
@onready var deck_manager: Deck_Manager = GM.deck_manager
@onready var parent: Node = get_parent()
@onready var card_display_box = preload("res://Assets/Scenes/DeckCreatorDisplay.tscn")
var current_deck = []
var all_cards = []
var purchased_cards = []

var min_deck_size:
	get:
		return Stats.gen_min_deck_size

var max_deck_size:
	get:
		return Stats.gen_max_deck_size

## Resizing information & startup
func _ready():
	get_viewport().size_changed.connect(move_position)
	move_position();
	Events.add_card_to_deck.connect(add_to_deck)
	Events.remove_card_from_deck.connect(remove_from_deck)
	Events.unlock_card.connect(card_unlocked)

func move_position():
	self.position.x = 0
## ---

## Deck Creation Management
func get_all_cards():
	return deck_manager.get_all_cards()

func get_default_deck():
	return deck_manager.get_default_deck()

func open_creator_menus():
	if !self.visible:
		return
	if all_cards.size() <= 0:
		all_cards = get_all_cards()
	refresh_deck()
	update_suits()
	update_deck_stats()

func refresh_deck():
	current_deck.assign(deck_manager.get_deck_list())

func card_unlocked(_card: Card):
	update_suits()

func update_suits():
	for n in 5:
		display_suit(n)



##Use different numbers for different suits:
##[codeblock]
## 0 - cups [br]
## 1 - wands [br]
## 2 - pentacles [br]
## 3 - swords [br]
## 4 - majors
##[/codeblock]
func display_suit(suit : int):
	var cards_in_suit = []
	for card: Card in all_cards:
		if card.card_suit == suit:
			cards_in_suit.append(card)
	#failsafe for while cards don't exist yet
	if cards_in_suit.size() <= 0:
		pass
	var box_count = 0
	for n in cards_in_suit:
		var addable: bool
		var removable: bool
		var card_count = current_deck.count(n)
		var cards_of_suit_in_deck = 0

		if n.card_suit == ID.Suits.MAJOR:
			for card in current_deck:
				if card.card_suit == ID.Suits.MAJOR:
					cards_of_suit_in_deck +=1

		"""
		This bit needs some work; i need it to recognise when a specific card is addble or removable via the Stats menu, 
		it needs to iterate every card I think...
		"""
		if card_count >= Stats.card_max_quant(n) || current_deck.size() >= max_deck_size:
			addable = false
		elif n.card_suit == ID.Suits.MAJOR && cards_of_suit_in_deck >= Stats.card_max_quant(n):
			addable = false
		else:
			addable = true


		if card_count > 0 && current_deck.size() > min_deck_size:
			removable = true
		else:
			removable = false
		
		panel_displays[suit].displays_list[box_count].update_display(n, addable, removable, card_count)
		# if current_deck.size() >= max_deck_size:
		# 	panel_displays[suit].displays_list[box_count].stop_add_card(true)
		# else:
		# 	panel_displays[suit].displays_list[box_count].stop_add_card(false)
		# if current_deck.size() <= min_deck_size:
		# 	panel_displays[suit].displays_list[box_count].stop_remove_card(true)
		# else:
		# 	panel_displays[suit].displays_list[box_count].stop_remove_card(false)
		box_count +=1



func add_to_deck(card: Card):
	current_deck.append(card)
	deck_manager._select_deck(current_deck)
	update_suits()
	update_deck_stats()

func remove_from_deck(card: Card):
	var index: int = current_deck.find(card)
	if index >= 0:
		current_deck.remove_at(index)
	else:
		print("Card not found in deck to remove")
	deck_manager._select_deck(current_deck)
	update_suits()
	update_deck_stats()
	
func update_deck_stats():
	deck_stats_display.set_deck_stats(current_deck.size(), min_deck_size, max_deck_size)

#if card is not purchased && not in default, then be purchasable
#if card is pre-purchased or default, then be available to add/remove to deck

		
