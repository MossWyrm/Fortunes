extends BaseGrowthFormula
class_name ExponentialGrowth

func apply_formula(purchased, base_value, _additional_value) -> int:
	return base_value ** purchased