extends BaseGrowthFormula
class_name SuperlinearGrowth

func apply_formula(purchased, base_value, additional_value) -> int:
	return (purchased**additional_value) * base_value