extends BaseGrowthFormula
class_name LinearGrowth

func apply_formula(purchased, base_value, _additional_value) -> int:
	# Fixed: Use (purchased + 1) to handle 0-purchase case properly
	# First purchase costs base_value, second costs 2*base_value, etc.
	return (purchased + 1) * base_value