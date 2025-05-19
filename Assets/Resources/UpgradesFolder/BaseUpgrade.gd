extends Resource
class_name BaseUpgrade

@export_group("Values")
@export var title: String
@export_multiline var description: String
@export var times_purchased: int
@export var initial_cost: float
@export var growth_type: BaseGrowthFormula

@export_group("Effects")
@export_enum("General","Cups","Wands","Pentacles","Swords","Major") var suit_to_upgrade: String
@export var stat_name : String
@export_enum(	"+","-","*","/") var effect_type: String
@export var effect_value: float

func _cost():
	return growth_type.apply_formula(times_purchased, initial_cost)

func _trigger():
	# FIND STAT
	var script: GDScript = Stats.get_script()
	for variable in script.get_script_property_list():
		if variable.name == stat_name:
			var stat = Stats.get(variable.name)
			if stat == null:
				print("Stat not found")
				break
			else:
				print(variable.name + " upgraded.")
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
				Stats.set(variable.name, stat)
				break
				