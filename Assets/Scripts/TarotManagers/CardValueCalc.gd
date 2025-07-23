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
	if majors_node.devil_active():
		if majors_node.devil_forced():
			Events.emit_skip_choice(true)
			majors_node.devil_use()
			Events.emit_update_suit_displays()
			return
		Events.emit_choose_skip()
		if await Events.skip_choice:
			majors_node.devil_use()
			Events.emit_update_suit_displays()
			return
	if majors_node.wheel_requires_check():
		majors_node.wheel_trigger(card.card_suit)
	if _pentacles_queen_check(flipped):
		flipped = !flipped
	swords_node.update_swords(flipped)
		
	var base_value: int = base_calc(card, flipped)
	var main_value: int = await main_calc(card,base_value,flipped)
	var post_value: int = post_calc(main_value)

	Events.emit_update_currency(post_value)
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
			return majors_node.get_display()
		_:
			return {}
			
func wand_knight_value() -> float:
	return wands_node.wand_knight_multi() if wands_node.wand_knight_check() else 1.0
	
func _pentacles_queen_check(flipped) -> bool:
	return pentacles_node.check_queen_pent(flipped)
	
func base_calc(card: Card, flipped: bool) -> int:
	var base_value: int = 0
	match card.card_suit:
		ID.Suits.CUPS:
			base_value = cups_node.get_base_value(card.card_default_value)
		ID.Suits.WANDS:
			base_value = wands_node.get_base_value(card.card_default_value)
		ID.Suits.PENTACLES:
			base_value = pentacles_node.get_base_value(card.card_default_value)
		ID.Suits.SWORDS:
			base_value = swords_node.get_base_value(card.card_default_value)
		ID.Suits.MAJOR:
			base_value = majors_node.get_base_value(card.card_default_value)
		_:
			print("card doesn't have suit")
			return 0
	base_value += majors_node.get_emperor()
	if majors_node.star_active(flipped):
		base_value = majors_node.star_trigger(base_value)
	majors_node.update_empress(base_value)
	majors_node.update_chariot(base_value)
	return base_value
	
func main_calc(card: Card, base_value: int, flipped: bool) -> int:
	var card_val: int = 0
	match card.card_suit:
		ID.Suits.CUPS:
			card_val = cups_node.draw(card, base_value, flipped)
		ID.Suits.WANDS:
			card_val = wands_node.draw(card, base_value, flipped)
		ID.Suits.PENTACLES:
			card_val = pentacles_node.draw(card, base_value, flipped)
		ID.Suits.SWORDS:
			card_val = swords_node.draw(card, base_value, flipped)
		ID.Suits.MAJOR:
			card_val = await majors_node.draw(card, base_value, flipped)
	return card_val
	
func post_calc(value: int) -> int:
	var card_val: int = roundi(float(value) * wand_knight_value())

	if card_val < 0:
		card_val = pentacles_node.use_pentacles(card_val)
	card_val += majors_node.get_empress()
	if majors_node.wheel_active():
		card_val = majors_node.wheel_mod(card_val)
	if majors_node.temperance_active():
		card_val = majors_node.temperance_trigger(card_val)
	if majors_node.tower_active():
		card_val = majors_node.tower_trigger(card_val)
	return card_val