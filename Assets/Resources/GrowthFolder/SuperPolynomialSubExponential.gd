extends BaseGrowthFormula
class_name SuperPolynomialSubExponential
## Description: Grows faster than any polynomial, but slower than any exponential.
## Example function: x^logx
## Example sequence: 1, 3, 6, 13, 24, 44, 75, 124, 200...
## Explanation: Its behaviour is closer to an exponential than a polynomial, but still is bounded by it.
## Possible uses: Now this is a very interesting function. People usually use exponential growth for prices to slow down progression. Using this function, we would achieve the same slow down in the long run, but the process would take longer, increasing the progression curve of players.

func apply_formula(_purchased, _base_value, _additional_value: float = 1.0) -> int:
	return _base_value * pow(_purchased, _additional_value*log(_purchased))