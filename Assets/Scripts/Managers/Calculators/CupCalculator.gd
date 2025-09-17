extends BaseCalculator
class_name CupCalculator

### --- State ---
var cup_stats: CupStats
var _page_size_mod: int = 0
var _cups: Dictionary = {}

### --- Initialization ---
func _init():
	if _cups.size() < 1:
		_cups[_cups.size()] = 0
	DebugManager.print_card_effects("CupCalculator: Initialized with empty cup", DebugManager.DebugLevel.VERBOSE)

func set_game_state(state: GameState):
	super.set_game_state(state)
	assert(state and state.stats and state.stats.cup_stats, "CupCalculator requires cup_stats to be present in GameState!")
	cup_stats = state.stats.cup_stats
	DebugManager.print_card_effects("CupCalculator: Game state set - vessel_size: %d, vessel_quantity: %d, page_mod: %.2f" % [cup_stats.vessel_size, cup_stats.vessel_quantity, cup_stats.page_modifier], DebugManager.DebugLevel.INFO)

### --- Tracker Methods ---
func shuffle(safely: bool) -> void:
	DebugManager.print_card_effects("CupCalculator: Shuffle called - safely: %s, current cups: %d, page_mod: %d" % [str(safely), _cups.size(), _page_size_mod], DebugManager.DebugLevel.INFO)
	if safely:
		return
	_page_size_mod = 0
	while _cups.size() > 1:
		remove_cup()
	_cups[0] = 0
	DebugManager.print_card_effects("CupCalculator: Shuffle completed - cups reset to: %s" % str(_cups), DebugManager.DebugLevel.INFO)

func get_max_size() -> int:
	var base_size = cup_stats.vessel_size
	# Apply multiplicative upgrade first, then add page modifier
	var multiplied_size = int(base_size * cup_stats.vessel_size_multiplier)
	return multiplied_size + _page_size_mod

func add_cup() -> void:
	var max_cups = cup_stats.vessel_quantity
	if _cups.size() >= max_cups:
		DebugManager.print_card_effects("CupCalculator: Cannot add cup - already at max quantity: %d" % max_cups, DebugManager.DebugLevel.WARNING)
		return
	_cups[_cups.size()] = 0
	DebugManager.print_card_effects("CupCalculator: Added new cup - total cups: %d" % _cups.size(), DebugManager.DebugLevel.VERBOSE)

func remove_cup() -> void:
	if _cups.size() <= 1:
		DebugManager.print_card_effects("CupCalculator: Cannot remove cup - only 1 cup remaining, clearing it instead", DebugManager.DebugLevel.VERBOSE)
		_cups[0] = 0
	else:
		_cups.erase(_cups.size()-1)
		DebugManager.print_card_effects("CupCalculator: Removed cup - total cups: %d" % _cups.size(), DebugManager.DebugLevel.VERBOSE)

func update_cups(value: int, _flipped: bool = false) -> void:
	var max_size = get_max_size()
	var initial_total = bonus()
	DebugManager.print_card_effects("CupCalculator: Updating cups by %d (max_size: %d, current total: %d)" % [value, max_size, initial_total], DebugManager.DebugLevel.VERBOSE)
	
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
		if remaining > 0:
			DebugManager.print_card_effects("CupCalculator: Could not add all value - %d remaining (cups at capacity)" % remaining, DebugManager.DebugLevel.WARNING)
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
		if remaining > 0:
			DebugManager.print_card_effects("CupCalculator: Could not remove all value - %d remaining (cups empty)" % remaining, DebugManager.DebugLevel.WARNING)
	
	var final_total = bonus()
	DebugManager.print_card_effects("CupCalculator: Cup update completed - total changed from %d to %d" % [initial_total, final_total], DebugManager.DebugLevel.VERBOSE)

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
	var page_mod = cup_stats.page_modifier * cup_stats.page_multiplier  # Apply multiplier upgrade
	var old_mod = _page_size_mod
	var total_size: float
	if flipped:
		total_size = (1 - page_mod) * float(base_size)
	else:
		total_size = (1 + page_mod) * float(base_size)
	_page_size_mod = roundi(total_size - base_size)
	DebugManager.print_card_effects("CupCalculator: Page drawn (flipped: %s) - size modifier changed from %d to %d (page_mod: %.3f)" % [str(flipped), old_mod, _page_size_mod, page_mod], DebugManager.DebugLevel.INFO)


### --- Calculation Methods ---
func calculate_base_value(card: Card, _flipped: bool) -> int:
	# Apply integer bonus first
	var base_result = card.value + cup_stats.basic_value

	# Then apply multiplicative bonus and round
	var result = base_result * cup_stats.basic_value_multiplier

	# Apply synergy multipliers if available
	if game_state and game_state.stats:
		result *= game_state.stats.cups_base_multiplier
		result *= game_state.stats.arcana_synergy_multiplier

	var final_result = int(result)
	DebugManager.print_card_effects("CupCalculator: Base value calculated - card: %d + basic: %d = %d, multiplier: %.3f, cups_base: %.3f, arcana_synergy: %.3f, final: %d" % [card.value, cup_stats.basic_value, base_result, cup_stats.basic_value_multiplier, game_state.stats.cups_base_multiplier if game_state and game_state.stats else 1.0, game_state.stats.arcana_synergy_multiplier if game_state and game_state.stats else 1.0, final_result], DebugManager.DebugLevel.VERBOSE)
	return final_result

func calculate_main_value(card: Card, base_value: int, flipped: bool) -> int:
	var pre_bonus = bonus()
	var result = _route_card_calculation(card, base_value, flipped)
	var post_bonus = bonus()
	DebugManager.print_card_effects("CupCalculator: Main calculation completed - card: %s (flipped: %s), result: %d, bonus changed from %d to %d" % [Tools.get_card_title(card), str(flipped), result, pre_bonus, post_bonus], DebugManager.DebugLevel.INFO)
	return result

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
	DebugManager.print_card_effects("CupCalculator: Knight effect - %s %d cards from deck (flipped: %s)" % ["removing" if flipped else "adding", knight_mod, str(flipped)], DebugManager.DebugLevel.INFO)
	for _i in range(knight_mod):
		if flipped:
			game_state.deck_manager.remove_random_card_by_suit(DataStructures.SuitType.CUPS)
		else:
			game_state.deck_manager.add_random_card_by_suit(DataStructures.SuitType.CUPS)
	return bonus() + val

func _queen(value: int, flipped: bool) -> int:
	var queen_mod = cup_stats.queen_modifier
	var initial_cups = _cups.size()
	DebugManager.print_card_effects("CupCalculator: Queen effect - %s %d cups (flipped: %s)" % ["removing" if flipped else "adding", queen_mod, str(flipped)], DebugManager.DebugLevel.INFO)
	for _i in range(queen_mod):
		if flipped:
			remove_cup()
		else:
			add_cup()
	DebugManager.print_card_effects("CupCalculator: Queen effect completed - cups changed from %d to %d" % [initial_cups, _cups.size()], DebugManager.DebugLevel.VERBOSE)
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	return bonus() + val

func _king(value: int, flipped: bool) -> int:
	var val = _value_modifier(value, flipped)
	update_cups(val, flipped)
	var pre_bonus = bonus()
	if flipped:
		DebugManager.print_card_effects("CupCalculator: King effect - emptying all cups", DebugManager.DebugLevel.INFO)
		empty_cups()
	else:
		DebugManager.print_card_effects("CupCalculator: King effect - filling all cups", DebugManager.DebugLevel.INFO)
		fill_cups()
	var post_bonus = bonus()
	DebugManager.print_card_effects("CupCalculator: King effect completed - total changed from %d to %d" % [pre_bonus, post_bonus], DebugManager.DebugLevel.VERBOSE)
	return bonus() + val

### --- Utility ---
func get_display_state() -> Dictionary:
	var dict: Dictionary = {
		"cups": _cups.duplicate(),
		"page_size_mod": _page_size_mod
	}
	return dict

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

### --- Death Reset ---
func death_reset(clear_positive: bool) -> int:
	var effects_cleared: int = 0
	
	if clear_positive:
		# Clear positive cup effects (cups with positive values)
		var has_positive_cups = false
		for cup_value in _cups.values():
			if cup_value > 0:
				has_positive_cups = true
				break
		if has_positive_cups:
			for cup in _cups.keys():
				if _cups[cup] > 0:
					_cups[cup] = 0
			effects_cleared += 1
		
		# Clear positive page size modifier
		if _page_size_mod > 0:
			_page_size_mod = 0
			effects_cleared += 1
	else:
		# Clear negative cup effects (negative page size modifier)
		if _page_size_mod < 0:
			_page_size_mod = 0
			effects_cleared += 1
	
	return effects_cleared