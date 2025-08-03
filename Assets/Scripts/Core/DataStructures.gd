extends RefCounted
class_name DataStructures

# Core enums

enum SuitType { CUPS, WANDS, PENTACLES, SWORDS, MAJOR, NONE }
enum CurrencyType { CLAIRVOYANCE, PACK }
enum GameLayer { DECK, PACK, BONES, POUCH, ALL }
enum CardState { INACTIVE, POSITIVE, NEGATIVE, UNKNOWN }
enum DeckOperation { ADD, REMOVE, SHUFFLE, CLEAR }
enum AnimationType { DRAW, FLIP, SHUFFLE, UPGRADE }
enum SFXType { CARD_FLIP, MENU_TAP, MENU_DING, PAGE_TURN }
enum MusicType { MAIN_THEME, VICTORY, DEFEAT }
enum GrowthType {LINEAR, SUPERLINEAR, SUBEXPONENTIAL, EXPONENTIAL, SLOW_EXPONENTIAL}

# Card data structure
class Card:
	var id: int
	var suit: SuitType
	var value: int
	var is_unlocked: bool
	var is_flipped: bool
	
	func _init(card_id: int, card_suit: SuitType, card_value: int):
		id = card_id
		suit = card_suit
		value = card_value
		is_unlocked = false
		is_flipped = false

# Card calculation result
class CardCalculationResult:
	var base_value: int
	var modified_value: int
	var final_value: int
	var clairvoyance_change: int
	var effects_applied: Array[String]
	
	func _init():
		base_value = 0
		modified_value = 0
		final_value = 0
		clairvoyance_change = 0
		effects_applied = []

# Tooltip data
class TooltipData:
	var title: String
	var description: String
	var card: DataStructures.Card
	var color: Color
	
	func _init(tooltip_title: String, tooltip_description: String, tooltip_card: DataStructures.Card, tooltip_color: Color = Color.WHITE):
		title = tooltip_title
		description = tooltip_description
		color = tooltip_color
		card = tooltip_card

# Suit state data
class SuitState:
	var suit: SuitType
	var is_active: bool
	var charges: int
	var value: float
	var modifiers: Dictionary
	
	func _init(suit_type: SuitType):
		suit = suit_type
		is_active = false
		charges = 0
		value = 0.0
		modifiers = {}

# Upgrade data
class UpgradeData:
	enum UpgradeType {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, GENERAL = 5, PACK = 6}
	enum OperationType {ADD, SUBTRACT, MULTIPLY, DIVIDE}
	var id: String
	var name: String
	var description: String
	var base_cost: float
	var max_purchases: int
	var times_purchased: int
	var stat_name: String
	var effect_value: float
	var operation: OperationType
	var formula: DataStructures.GrowthType
	var additional_formula_input: float
	
	func _init(upgrade_id: String, upgrade_name: String, upgrade_description: String, upgrade_cost: float, upgrade_max: int, upgrade_stat: String, upgrade_effect: float, upgrade_formula: DataStructures.GrowthType, upgrade_additional_formula_input: float = 0.0):
		id = upgrade_id
		name = upgrade_name
		description = upgrade_description
		base_cost = upgrade_cost
		max_purchases = upgrade_max
		times_purchased = 0
		stat_name = upgrade_stat
		effect_value = upgrade_effect 
		formula = upgrade_formula
		additional_formula_input = upgrade_additional_formula_input