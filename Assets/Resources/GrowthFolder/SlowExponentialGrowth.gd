extends BaseGrowthFormula
class_name SlowExponentialGrowth

func apply_formula(purchased, base_value, additional_value) -> int:
	# Fixed: Simplified slow exponential that handles 0-purchase case properly
	# Uses additional_value as the growth rate divider for slower scaling
	var growth_rate = additional_value if additional_value > 1.0 else 2.0
	var exponent = 1.0 + (purchased / growth_rate)
	return int(pow(base_value, exponent))