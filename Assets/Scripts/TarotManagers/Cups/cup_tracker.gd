extends suit_tracker
class_name cup_tracker

# Tracks the state of Cups suit (number of cups, their values, etc.)

var _page_size_mod: int = 0
var _max_size:int:
	get:
		return Stats.cup_vessel_size + _page_size_mod
var _cups: Dictionary[int,int] = {}

func _init() -> void:
	if _cups.size() < 1:
		add_cup()

# Updates all cups with the given value
func update(value, _flipped = false) -> void:
	for cup in _cups.keys():
		_cups[cup] += value
		if _cups[cup] > _max_size:
			_cups[cup] = _max_size
		if _cups[cup] < 0:
			_cups[cup] = 0

# Adds a new cup if under the max allowed
func add_cup() -> void:
	if _cups.size() >= Stats.cup_vessel_quant:
		pass
	_cups[_cups.size()] = 0

# Removes a cup, or empties the last if only one remains
func remove_cup() -> void:
	if(_cups.size() <= 1):
		_cups[0] = 0
	else:
		_cups.erase(_cups.size()-1)
		
# Resets cups on unsafe shuffle
func shuffle(safely) -> void:
	if safely == true:
		return
	else:
		_page_size_mod = 0
		for N in _cups.size():
			remove_cup()

# Returns the total value of all cups
func bonus() -> int:
	var totalValue: int = 0
	for cup in _cups.keys():
		totalValue += _cups[cup]
	return totalValue

# Empties all cups
func empty_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = 0

# Fills all cups to max
func fill_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = _max_size

# Returns the cup state for display
func get_display() -> Dictionary:
	return _cups
	
# Adjusts page size modifier based on flipped state
func draw_page(flipped: bool) -> void:
	var total_size: float
	if flipped:
		total_size = (1 - Stats.cup_page_mod) * float(Stats.cup_vessel_size)
	else:
		total_size = (1+ Stats.cup_page_mod) * float(Stats.cup_vessel_size)
	_page_size_mod = roundi(total_size - Stats.cup_vessel_size)