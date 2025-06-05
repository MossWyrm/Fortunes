extends suit_tracker
class_name cup_tracker

var _max_size:int:
	get:
		return Stats.cup_max_size + Stats.cup_max_size_modifier
var _cups: Dictionary[int,int] = {}

func _init() -> void:
	if _cups.size() < 1:
		add_cup()

func update(value, _flipped = false) -> void:
	for cup in _cups.keys():
		_cups[cup] += value
		if _cups[cup] > _max_size:
			_cups[cup] = _max_size
		if _cups[cup] < 0:
			_cups[cup] = 0

func add_cup() -> void:
	if _cups.size() >= Stats.cup_max_quant:
		pass
	_cups[_cups.size() + 1] = 0

func remove_cup() -> void:
	if(_cups.size() <= 1):
		_cups[0] = 0
	else:
		_cups.erase(_cups.size()-1)
		
func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		Stats.cup_max_size_modifier = 0
		for N in _cups.size():
			remove_cup()

func bonus() -> int:
	var totalValue: int = 0
	for cup in _cups.keys():
		totalValue += _cups[cup]
	return totalValue

func get_display() -> Dictionary:
	return _cups

func empty_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = 0

func fill_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = _max_size