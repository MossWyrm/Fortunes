extends BaseGrowthFormula
class_name LinearGrowth

func apply_formula(purchased, base_value, _additional_value) -> int:
	return purchased * base_value