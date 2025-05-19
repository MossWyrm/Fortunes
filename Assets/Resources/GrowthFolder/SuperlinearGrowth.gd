extends BaseGrowthFormula
class_name SuperlinearGrowth

@export var exponent: float

func apply_formula(purchased, base_value):
	return (purchased**exponent) * base_value