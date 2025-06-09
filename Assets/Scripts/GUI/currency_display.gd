extends Label
class_name CurrencyDisplay
	
func update_text(value):
	if value >= 100 || value == 0:
		self.text = str("%d" % value)
	elif value < 100 && value > 10:
		self.text = str("%.1f" % value)
	else:
		self.text = str("%.2f" % value)

