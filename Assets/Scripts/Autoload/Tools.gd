extends Node
class_name Tools

static func get_shorthand(number: int) -> String:
	if number < 1000:
		return str(number)
	var suffix: Array     = ["K","M","B","T","Qa","Qi","Sx","Se","Oc","No"]
	var suffix_index: int = -1
	var numfloat: float   = float(number)
	while numfloat >= 1000.0:
		suffix_index += 1
		numfloat /= 1000.0
	
	var output_num: String
	if numfloat >= 100 || numfloat == 0:
		output_num = str("%d" % numfloat)
	elif numfloat < 100 && numfloat > 10:
		output_num = str("%.1f" % numfloat)
	else:
		output_num = str("%.2f" % numfloat)
	
	return str("%s%s"%[output_num, suffix[suffix_index]])

static func create_card_tooltip(card: DataStructures.Card) -> DataStructures.TooltipData:
	var tooltip: DataStructures.TooltipData = DataStructures.TooltipData.new(card.name, card.description, null, Color.WHITE, ResourceAutoload.get_card_texture(card))
	return tooltip

static func create_buff_tooltip(card_id: int) -> DataStructures.TooltipData:
	var card: DataStructures.Card = GameManager.game_state.deck_manager.get_card(card_id)
	var tooltip: DataStructures.TooltipData = DataStructures.TooltipData.new(card.name, card.description, null, Color.WHITE, ResourceAutoload.get_card_texture(card))
	return tooltip