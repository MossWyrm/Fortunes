extends Node
class_name Upgrade

var title: String
var description: String
var id: int = 0
var times_purchased: int = 0
var initial_cost: float
var currency_type: ID.CurrencyType = ID.CurrencyType.CLAIRVOYANCE
var growth_type: BaseGrowthFormula
var growth_mod: float = 0
var cost: int:
	get:
		return growth_type.apply_formula(times_purchased + 1, initial_cost, growth_mod)
var stat_name : String
var effect_type: ID.Operation
var effect_value
var max_purchases: int
var upgrade_disabled: bool:
	get:
		return max_purchases > 0 && times_purchased >= max_purchases


func _init(upg_name: String, upg_desc: String, card_id: int, init_cost: float, growth: BaseGrowthFormula, growth_modifier: float, stat: String, operation: ID.Operation, effect, max_p: int = -1, currency_upgrade_type: ID.CurrencyType = ID.CurrencyType.CLAIRVOYANCE):
	title = upg_name
	description = upg_desc
	id = card_id
	initial_cost = init_cost
	growth_type = growth
	growth_mod = growth_modifier
	stat_name = stat
	effect_type = operation
	effect_value = effect
	max_purchases = max_p
	currency_type = currency_upgrade_type

func trigger() -> void:
	if stat_name not in Stats:
		print("Stat not found")
		return

	var stat = Stats.get(stat_name)
	if effect_value is bool:
		stat = effect_type
	else:
		match effect_type:
			ID.Operation.ADD: stat += effect_value	
			ID.Operation.SUBTRACT: stat -= effect_value
			ID.Operation.MULTIPLY: stat *= effect_value
			ID.Operation.DIVIDE: stat /= effect_value
			_: print("Error deciidng stat effect.")

	print(stat_name + " upgraded.")
	Stats.set(stat_name, stat)
			