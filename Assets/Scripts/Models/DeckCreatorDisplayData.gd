extends RefCounted
class_name DeckCreatorDisplayData
##
## Data structure for holding deck creation display information.
##
## This class is used to encapsulate all relevant data needed for displaying
## the deck creation UI, including card options, costs, and other metadata.

# Data required for displays
var card_id: int
var display_title: String
var card_background: Texture2D
var card_overlay: Texture2D
var is_unlocked: bool

# Card Locked Displays
var cost_text: String
var cost_color: Color
var is_affordable: bool

# Card Unlocked Displays
var is_card_addable: bool
var is_card_removable: bool
var amount_in_deck: int = 0


func _init(card: Card, deck_creator: DeckCreator) -> void:
	if not card:
		DebugManager.print_deck_operations("DeckCreatorDisplayData: Cannot initialize with null card")
		return

	# Card Information
	card_id = card.id
	display_title = Tools.get_card_title(card)
	is_unlocked = card.is_unlocked
	
	# Get Textures
	var textures = PreloadedResources.get_card_texture(card)
	card_background = textures["background"]
	card_overlay = textures["overlay"]

	# Card Costs
	is_affordable = deck_creator.can_afford(card.id)
	cost_text = "Cost: " + Tools.get_shorthand(int(deck_creator.get_card_cost(card.id)))
	cost_color = DataStructures.core_color.GOOD if is_affordable else DataStructures.core_color.BAD

	# Unlocked States
	is_card_addable = deck_creator.can_add_card(card.id)
	is_card_removable = deck_creator.can_remove_card(card.id)
	amount_in_deck = deck_creator.get_count_in_deck(card.id)

	DebugManager.print_deck_operations("DeckCreatorDisplayData: Initialized display data for card %s.\nTitle: %s\nUnlocked: %s\nAffordable: %s\nAddable: %s\nRemovable: %s\nIn Deck: %d" % [str(card.id), display_title, str(is_unlocked), str(is_affordable), str(is_card_addable), str(is_card_removable), amount_in_deck], DebugManager.DebugLevel.VERBOSE)