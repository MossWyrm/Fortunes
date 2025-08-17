extends RefCounted
class_name CardDescriptionFactory

## Factory for creating card descriptions
## Routes cards to appropriate description classes

static func get_description(card: Card, bb_formatted: bool = false) -> Dictionary:
	var description_class = _get_description_class(card)
	return description_class.build_description(card, bb_formatted)

static func _get_description_class(card: Card):
	var card_id = card.card_id_num
	
	# Major Arcana (500+)
	if GameConstants.is_major_card(card_id):
		return MajorCardDescription
	
	# Suit cards by hundreds
	var suit_hundreds = card_id / GameConstants.CARD_ID_SUIT_MULTIPLIER
	match suit_hundreds:
		1: return CupCardDescription
		2: return WandCardDescription
		3: return PentacleCardDescription
		4: return SwordCardDescription
		_: return BaseCardDescription

# Convenience method for backwards compatibility
static func get_card_description(card: Card, bb_formatted: bool = false) -> Dictionary:
	return get_description(card, bb_formatted)
