extends BaseGrowthFormula
class_name SlowExponentialGrowth

func apply_formula(purchased, base_value, additional_value) -> int:
	var value: int = 1 if additional_value > 1 else 0
	return base_value ** (value + ((purchased-1) / additional_value))