extends card_calc
class_name majors_calc

@onready var tracker: majors_tracker = get_child(0)

#TODO: Finish the implementation of the remaining Majors

func draw(card: Card, _value: int, flipped = false) -> int:
	match card.card_id_num % 100:
		1: return _fool(flipped)
		2: return await _magician(flipped)
		3: return _high_priestess(flipped)
		4: return _empress(flipped)
		5: return _emperor(flipped) 
		6: return _heirophant(flipped)
		7: return _lovers(flipped)
		8: return _chariot(flipped)
		9: return _strength(flipped)
		10: return _hermit(flipped)
		11: return await _wheel_of_fortune(flipped)
		12: return _justice(flipped)
		13: return _hanged_man(flipped)
		14: return _death(flipped)
		15: return _temperance(flipped)
		16: return _devil(flipped)
		17: return _tower(flipped)
		18: return _star(flipped)
		19: return _moon(flipped)
		20: return _sun(flipped)
		21: return _judgement(flipped)
		_:
			print("failed to find card")
			return 0
	
func _fool(flipped: bool) -> int:
	Events.emit_shuffle(!flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _magician(flipped: bool) -> int:
	await tracker.draw_magician(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _high_priestess(_flipped: bool) -> int:
	return 0
	
func _empress(flipped: bool) -> int:
	tracker.draw_empress(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _emperor(flipped: bool) -> int:
	tracker.draw_emperor(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _heirophant(_flipped: bool) -> int:
	return 0
	
func _lovers(flipped: bool) -> int:
	tracker.draw_lovers(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _chariot(flipped: bool) -> int:
	tracker.draw_chariot(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _strength(_flipped: bool) -> int:
	return 0
	
func _hermit(flipped: bool) -> int:
	tracker.draw_hermit(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _wheel_of_fortune(flipped: bool) -> int:
	await tracker.draw_wheel_of_fortune(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _justice(_flipped: bool) -> int:
	return 0
	
func _hanged_man(_flipped: bool) -> int:
	return 0
	
func _death(_flipped: bool) -> int:
	return 0
	
func _temperance(flipped: bool) -> int:
	tracker.draw_temperance(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _devil(_flipped: bool) -> int:
	return 0
	
func _tower(flipped: bool) -> int:
	tracker.draw_tower(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _star(flipped: bool) -> int:
	tracker.draw_star()
	Events.emit_card_animation_major(flipped)
	return 0
	
func _moon(flipped: bool) -> int:
	tracker.draw_moon(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _sun(flipped: bool) -> int:
	tracker.draw_sun(flipped)
	Events.emit_card_animation_major(flipped)
	return 0
	
func _judgement(_flipped: bool) -> int:
	return 0

func get_display() -> Dictionary: 			return tracker.get_display()
func get_base_value(_value: int) -> int: 	return _value
func get_empress() -> int: 					return tracker.get_empress_value()
func update_empress(value) -> void:			tracker.update_empress(value)
func get_emperor() -> int: 					return tracker.get_emperor()
func update_chariot(value) -> void:			tracker.update_chariot(value)
func wheel_requires_check() -> bool: 		return tracker.requires_wheel_check
func wheel_trigger(suit: ID.Suits) -> void:	tracker.trigger_wheel_of_fortune(suit)
func wheel_active() -> bool:				return tracker.check_active(ID.MajorID.WHEEL_OF_FORTUNE)
func wheel_mod(value: int) -> int: 			return tracker.wheel_modifier(value)
func temperance_active() -> bool: 			return tracker.check_active(ID.MajorID.TEMPERANCE)
func temperance_trigger(value: int) -> int:	return tracker.trigger_temperance(value)
func tower_active() -> bool: 				return tracker.check_active(ID.MajorID.TOWER)
func tower_trigger(value:int) -> int: 		return tracker.trigger_tower(value)
func star_active(flipped: bool) -> bool: 	return tracker.check_star(flipped)
func star_trigger(value: int) -> int: 		return tracker.trigger_star(value)