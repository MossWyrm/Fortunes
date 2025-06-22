extends suit_tracker
class_name cup_tracker

var _page_size_mod: int = 0
var _max_size:int:
	get:
		return Stats.cup_vessel_size + _page_size_mod
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
	if _cups.size() >= Stats.cup_vessel_quant:
		pass
	_cups[_cups.size()] = 0

func remove_cup() -> void:
	if(_cups.size() <= 1):
		_cups[0] = 0
	else:
		_cups.erase(_cups.size()-1)
		
func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		_page_size_mod = 0
		for N in _cups.size():
			remove_cup()

func bonus() -> int:
	var totalValue: int = 0
	for cup in _cups.keys():
		totalValue += _cups[cup]
	return totalValue

func empty_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = 0

func fill_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = _max_size

func get_display() -> Dictionary:
	return _cups
	
func draw_page(flipped: bool) -> void:
	var total_size: float
	if flipped:
		total_size = (1 - Stats.cup_page_mod) * float(Stats.cup_vessel_size)
	else:
		total_size = (1+ Stats.cup_vessel_size) * float(Stats.cup_vessel_size)
	_page_size_mod = roundi(total_size - Stats.cup_vessel_size)