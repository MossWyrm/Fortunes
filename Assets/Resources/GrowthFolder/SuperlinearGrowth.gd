extends BaseGrowthFormula
class_name SuperlinearGrowth

func apply_formula(purchased, base_value, additional_value) -> int:
	return ((purchased+1)**additional_value) * base_value