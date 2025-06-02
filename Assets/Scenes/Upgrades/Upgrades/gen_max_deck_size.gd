extends Upgrade

#Upgrades Max Deck Size

func _scaling_formula():
	var output: float = 0
	# output = pow(float(times_purchased),(log(times_purchased)*0.4))
	output = times_purchased*times_purchased
	return output

func _trigger():
	Stats.gen_max_deck_size +=1