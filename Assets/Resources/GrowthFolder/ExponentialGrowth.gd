extends BaseGrowthFormula
class_name ExponentialGrowth

func apply_formula(purchased, base_value, additional_value) -> int:
	# Fixed: Use additional_value as growth multiplier, handle 0-purchase case
	# First purchase costs base_value, then base_value * multiplier^1, base_value * multiplier^2, etc.
	var multiplier = additional_value if additional_value > 1.0 else 2.0
	return int(base_value * pow(multiplier, purchased))