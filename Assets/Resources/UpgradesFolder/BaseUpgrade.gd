extends Resource
class_name BaseUpgrade

@export_group("Values")
@export var title: String
@export_multiline var description: String
@export var times_purchased: int
@export var initial_cost: float
@export var growth_type: BaseGrowthFormula

@export_group("Effects")
@export var suit_to_upgrade: ID.UpgradeType
@export var stat_name : String
@export_enum(	"+","-","*","/") var effect_type: String
@export var effect_value: float

func _cost():
	return growth_type.apply_formula(times_purchased, initial_cost)

func _trigger() -> void:
	
	if stat_name not in Stats:
		print("Stat not found")
		return
		
	var stat = Stats.get(stat_name)
	if effect_type == "+":
		stat += effect_value
	elif effect_type == "-":
		stat -= effect_value
	elif effect_type == "*":
		stat *= effect_value
	elif effect_type == "/":
		stat /= effect_value
	else:
		print("Error deciidng stat effect.")
		pass
	print(stat_name + " upgraded.")
	Stats.set(stat_name, stat)
			