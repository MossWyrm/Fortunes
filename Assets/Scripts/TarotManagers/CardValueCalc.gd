extends Node
class_name CVC

@export var cups_node: cups_calc
@export var wands_node: wands_calc
@export var pentacles_node: pentacles_calc
@export var swords_node: swords_calc
@export var majors_node: majors_calc


func _ready() -> void:
	GM.cv_manager = self
	Events.selected_card.connect(_calculate_card_value)
	
func _calculate_card_value(card: Card, flipped = false) -> void:
	var card_val: int = 0
	if _pentacles_queen_check(flipped):
		flipped = !flipped
	swords_node.update_swords(flipped)
	match card.card_suit:
		ID.Suits.CUPS:
			card_val = cups_node.draw(card, flipped)
		ID.Suits.WANDS:
			card_val = wands_node.draw(card, flipped)	
		ID.Suits.PENTACLES:
			card_val = pentacles_node.draw(card, flipped)
		ID.Suits.SWORDS:
			card_val = swords_node.draw(card, flipped)
		ID.Suits.MAJOR:
			card_val = await majors_node.draw(card, flipped)
	
	card_val = roundi(float(card_val) * wand_knight_value())
		
	if card_val < 0:
		card_val = pentacles_node.use_pentacles(card_val)
	Events.emit_update_currency_display(card_val)
	Events.emit_update_suit_displays()

	
func get_display(suit: ID.Suits) -> Dictionary:
	match suit:
		ID.Suits.CUPS:
			return cups_node.get_display()
		ID.Suits.WANDS:
			return wands_node.get_display()
		ID.Suits.PENTACLES:
			return pentacles_node.get_display()
		ID.Suits.SWORDS:
			return swords_node.get_display()
		ID.Suits.MAJOR:
			return {}
		_:
			return {}
			
func wand_knight_value() -> float:
	return wands_node.wand_knight_multi() if wands_node.wand_knight_check() else 1.0
	
func _pentacles_queen_check(flipped):
	return pentacles_node.check_queen_pent(flipped)
