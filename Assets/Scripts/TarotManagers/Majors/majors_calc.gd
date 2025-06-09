extends card_calc
class_name majors_calc

func draw(card: Card, _flipped = false) -> int:
	match card.card_id_num % 100:
		1:
			return _fool(_flipped)
		2:
			return await _magician(_flipped)
		3:
			return _high_priestess(_flipped)
		4:
			return _empress(_flipped)
		5:
			return _emperor(_flipped)
		6:
			return _heirophant(_flipped)
		7:
			return _lovers(_flipped)
		8:
			return _chariot(_flipped)
		9:
			return _strength(_flipped)
		10:
			return _hermit(_flipped)
		11:
			return _wheel_of_fortune(_flipped)
		12:
			return _justice(_flipped)
		13:
			return _hanged_man(_flipped)
		14:
			return _death(_flipped)
		15:
			return _temperance(_flipped)
		16:
			return _devil(_flipped)
		17:
			return _tower(_flipped)
		18:
			return _star(_flipped)
		19:
			return _moon(_flipped)
		20:
			return _sun(_flipped)
		21:
			return _judgement(_flipped)
		22:
			return _world(_flipped)
		_:
			print("failed to find card")
			return 0
	
func _fool(flipped: bool) -> int:
	Events.emit_shuffle(!flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _magician(flipped: bool) -> int:
	Events.emit_choose_suit()
	print("choose suit please")
	var suit = await Events.chosen_suit
	Events.emit_card_animation_major(flipped)
	print("suit chosen as %s"%[suit])
	for x in Stats.major_magician:
		if flipped:
			GM.deck_manager.remove_card(suit)
		else:
			GM.deck_manager.add_card_by_suit(suit)
	return 0
	
func _high_priestess(_flipped: bool) -> int:
	return 0
	
func _empress(_flipped: bool) -> int:
	return 0
	
func _emperor(_flipped: bool) -> int:
	return 0
	
func _heirophant(_flipped: bool) -> int:
	return 0
	
func _lovers(_flipped: bool) -> int:
	return 0
	
func _chariot(_flipped: bool) -> int:
	return 0
	
func _strength(_flipped: bool) -> int:
	return 0
	
func _hermit(_flipped: bool) -> int:
	return 0
	
func _wheel_of_fortune(_flipped: bool) -> int:
	return 0
	
func _justice(_flipped: bool) -> int:
	return 0
	
func _hanged_man(_flipped: bool) -> int:
	return 0
	
func _death(_flipped: bool) -> int:
	return 0
	
func _temperance(_flipped: bool) -> int:
	return 0
	
func _devil(_flipped: bool) -> int:
	return 0
	
func _tower(_flipped: bool) -> int:
	return 0
	
func _star(_flipped: bool) -> int:
	return 0
	
func _moon(_flipped: bool) -> int:
	return 0
	
func _sun(_flipped: bool) -> int:
	return 0
	
func _judgement(_flipped: bool) -> int:
	return 0
	
func _world(_flipped: bool) -> int:
	return 0