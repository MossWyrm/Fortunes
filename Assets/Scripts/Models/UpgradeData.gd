class_name UpgradeData
extends RefCounted

enum UpgradeType {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, GENERAL = 5, PACK = 6}
enum OperationType {ADD, SUBTRACT, MULTIPLY, DIVIDE}
var id: String
var name: String
var description: String
var base_cost: float
var max_purchases: int
var stat_name: String
var effect_value
var operation: OperationType
var formula: DataStructures.GrowthType
var additional_formula_input: float
var card_id: int = 0
var type: UpgradeType

func _init(upgrade_id: String, upgrade_name: String, upgrade_description: String, upgrade_cost: float, upgrade_max: int, upgrade_stat: String, upgrade_value, upgrade_operation: OperationType, upgrade_formula: DataStructures.GrowthType, upgrade_additional_formula_input: float, upgrade_type: UpgradeType, upgrade_card_id: int = 0):
    id = upgrade_id
    name = upgrade_name
    description = upgrade_description
    base_cost = upgrade_cost
    max_purchases = upgrade_max
    stat_name = upgrade_stat
    effect_value = upgrade_value
    operation = upgrade_operation
    formula = upgrade_formula
    additional_formula_input = upgrade_additional_formula_input
    type = upgrade_type
    card_id = upgrade_card_id