extends "res://Assets/Scenes/Upgrades/upgrade.gd"

#Upgrades Max Deck Size

func _scaling_formula():
	var output: float = 0
	# output = pow(float(times_purchased),(log(times_purchased)*0.4))
	output = initial_cost*times_purchased
	return output

func _trigger():
	Stats.sword_basic_quant +=1