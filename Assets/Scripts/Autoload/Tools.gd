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