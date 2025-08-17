extends BaseCalculator
class_name CupCalculator

### --- State ---
var cup_stats: CupStats
var _page_size_mod: int = 0
var _cups: Dictionary = {}

### --- Initialization ---
func _init():
	if _cups.size() < 1:
		add_cup()

func set_game_state(state: GameState):
	super.set_game_state(state)
	assert(state and state.stats and state.stats.cup_stats, "CupCalculator requires cup_stats to be present in GameState!")
	cup_stats = state.stats.cup_stats

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
	if safely:
		return
	_page_size_mod = 0
	while _cups.size() > 1:
		remove_cup()
	_cups[0] = 0

func get_max_size() -> int:
	var base_size = cup_stats.vessel_size
	return base_size + _page_size_mod

func add_cup() -> void:
	var max_cups = cup_stats.vessel_quantity
	if _cups.size() >= max_cups:
		return
	_cups[_cups.size()] = 0

func remove_cup() -> void:
	if _cups.size() <= 1:
		_cups[0] = 0
	else:
		_cups.erase(_cups.size()-1)

func update_cups(value: int, _flipped: bool = false) -> void:
	var max_size = get_max_size()
	if value > 0:
		var remaining = value
		for i in range(_cups.size()):
			var cup = i
			var space = max_size - _cups[cup]
			if space == 0:
				continue
			var add = min(space, remaining)
			_cups[cup] += add
			remaining -= add
			if remaining <= 0:
				break
	elif value < 0:
		var remaining = -value
		for i in range(_cups.size() - 1, -1, -1):
			var cup = i
			if _cups[cup] > 0:
				var take = min(_cups[cup], remaining)
				_cups[cup] -= take
				remaining -= take
				if remaining <= 0:
					break

func bonus() -> int:
	var total_value: int = 0
	for cup in _cups.keys():
		total_value += _cups[cup]
	return total_value

func empty_cups() -> void:
	for cup in _cups.keys():
		_cups[cup] = 0

func fill_cups() -> void:
	var max_size = get_max_size()
	for cup in _cups.keys():
		_cups[cup] = max_size

func draw_page(flipped: bool) -> void:
	var base_size = cup_stats.vessel_size
	var page_mod = cup_stats.page_modifier
	var total_size: float
	if flipped:
		total_size = (1 - page_mod) * float(base_size)
	else:
		total_size = (1 + page_mod) * float(base_size)
	_page_size_mod = roundi(total_size - base_size)


### --- Calculation Methods ---
func calculate_base_value(card: Card, _flipped: bool) -> int:
	return card.value + cup_stats.basic_value

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
	return _route_card_calculation(card, base_value, flipped)

func _basic(value: int, flipped: bool) -> int:
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	return bonus() + val

func _page(value: int, flipped: bool) -> int:
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	draw_page(flipped)
	return bonus() + val

func _knight(value: int, flipped: bool) -> int:
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	var knight_mod = cup_stats.knight_modifier
	for _i in range(knight_mod):
		if flipped:
			game_state.deck_manager.remove_random_card_by_suit(DataStructures.SuitType.CUPS)
		else:
			game_state.deck_manager.add_random_card_by_suit(DataStructures.SuitType.CUPS)
	return bonus() + val

func _queen(value: int, flipped: bool) -> int:
	var queen_mod = cup_stats.queen_modifier
	for _i in range(queen_mod):
		if flipped:
			remove_cup()
		else:
			add_cup()
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	return bonus() + val

func _king(value: int, flipped: bool) -> int:
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	if flipped:
		empty_cups()
	else:
		fill_cups()
	return bonus() + val

### --- Utility ---
func get_display_state() -> Dictionary:
	return _cups.duplicate()

func get_state_backup() -> Dictionary:
	return {
		"cups": _cups.duplicate(),
		"page_size_mod": _page_size_mod
	}

func restore_state_backup(backup: Dictionary):
	if backup.has("cups"):
		_cups = backup["cups"]
	if backup.has("page_size_mod"):
		_page_size_mod = backup["page_size_mod"]