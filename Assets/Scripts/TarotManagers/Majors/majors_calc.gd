extends card_calc
class_name majors_calc

func draw(card: Card, flipped = false) -> int:
	match card.card_id_num % 100:
		1:
			return _fool(flipped)
		2:
			return _magician(flipped)
		3:
			return _high_priestess(flipped)
		4:
			return _empress(flipped)
		5:
			return _emperor(flipped)
		6:
			return _heirophant(flipped)
		7:
			return _lovers(flipped)
		8:
			return _chariot(flipped)
		9:
			return _strength(flipped)
		10:
			return _hermit(flipped)
		11:
			return _wheel_of_fortune(flipped)
		12:
			return _justice(flipped)
		13:
			return _hanged_man(flipped)
		14:
			return _death(flipped)
		15:
			return _temperance(flipped)
		16:
			return _devil(flipped)
		17:
			return _tower(flipped)
		18:
			return _star(flipped)
		19:
			return _moon(flipped)
		20:
			return _sun(flipped)
		21:
			return _judgement(flipped)
		22:
			return _world(flipped)
		_:
			print("failed to find card")
			return 0
	
func _fool(flipped: bool) -> int:
	Events.emit_shuffle(!flipped)
	return 0
	
func _magician(flipped: bool) -> int:
	return 0
	
func _high_priestess(flipped: bool) -> int:
	return 0
	
func _empress(flipped: bool) -> int:
	return 0
	
func _emperor(flipped: bool) -> int:
	return 0
	
func _heirophant(flipped: bool) -> int:
	return 0
	
func _lovers(flipped: bool) -> int:
	return 0
	
func _chariot(flipped: bool) -> int:
	return 0
	
func _strength(flipped: bool) -> int:
	return 0
	
func _hermit(flipped: bool) -> int:
	return 0
	
func _wheel_of_fortune(flipped: bool) -> int:
	return 0
	
func _justice(flipped: bool) -> int:
	return 0
	
func _hanged_man(flipped: bool) -> int:
	return 0
	
func _death(flipped: bool) -> int:
	return 0
	
func _temperance(flipped: bool) -> int:
	return 0
	
func _devil(flipped: bool) -> int:
	return 0
	
func _tower(flipped: bool) -> int:
	return 0
	
func _star(flipped: bool) -> int:
	return 0
	
func _moon(flipped: bool) -> int:
	return 0
	
func _sun(flipped: bool) -> int:
	return 0
	
func _judgement(flipped: bool) -> int:
	return 0
	
func _world(flipped: bool) -> int:
	return 0