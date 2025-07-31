extends suit_tracker
class_name majors_tracker

var _major_states: Dictionary = {}

var empress_collection: Array[int] = []
var chariot_tracker: Array[int] = []
var wheel_suit: ID.Suits = ID.Suits.NONE
var wheel_checked: bool = false
var requires_wheel_check: bool:
	get:
		return !wheel_checked && check_active(ID.MajorID.WHEEL_OF_FORTUNE)
var stars_work_on_bad: bool = false
var moons_drawn: int = 0

var requires_initialization: Array[ID.MajorID] = [
	ID.MajorID.EMPRESS,
	ID.MajorID.EMPEROR,
	ID.MajorID.CHARIOT,
	ID.MajorID.WHEEL_OF_FORTUNE,
	ID.MajorID.TEMPERANCE,
	ID.MajorID.DEVIL,
	ID.MajorID.JUDGEMENT
]

func _ready() -> void:
	super._ready()
	for value in ID.MajorID.values():
		_major_states[value] = [ID.CardState.INACTIVE]
	for major_id in requires_initialization:
		_major_states[major_id].append(0)

func update(_value, _flipped = false) -> void:
	return

func shuffle(safely: bool = false) -> void:
	if safely:
		return
	for key in _major_states.keys():
		set_state(key, ID.CardState.INACTIVE) 
		if _major_states[key].size() >1:
			set_charges(key, 0)
	empress_collection.clear()
	stars_work_on_bad = false 
	moons_drawn = 0
	wheel_suit = ID.Suits.NONE
	
#region = "Magician"
func draw_magician(flipped: bool) -> void:
	Events.emit_choose_suit()
	var suit = await Events.chosen_suit
	for x in Stats.major_magician:
		if flipped:
			GM.deck_manager.remove_card(suit)
		else:
			GM.deck_manager.add_card_by_suit(suit)
#endregion
#region = "Empress"
## -----
## Handles Empress card logic, including drawing and updating the Empress value.
## -----

# Called when the Empress card is drawn
func draw_empress(flipped: bool) -> void:
	# Set the state to POSITIVE or NEGATIVE depending on flip
	set_state(ID.MajorID.EMPRESS, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)

# Updates the Empress collection with a new value
func update_empress(value: int) -> void:
	if value == 0:
		return
	empress_collection.append(abs(value))
	# Keep only the most recent N values, where N is major_empress stat
	while empress_collection.size() > Stats.major_empress:
		empress_collection.remove_at(0)
	set_charges(ID.MajorID.EMPRESS, abs(get_empress_value()))

# Calculates the Empress value based on state and collection
func get_empress_value() -> int:
	var multiplier := 0
	match get_state(ID.MajorID.EMPRESS):
		ID.CardState.POSITIVE:
			multiplier = 1
		ID.CardState.NEGATIVE:
			multiplier = -1
		_:
			multiplier = 0
	# Sum the collection and apply the multiplier
	return empress_collection.reduce(func(accum, number): return accum + number, 0) * multiplier
#endregion
#region = "Emperor"
func draw_emperor(flipped: bool) -> void:
	set_state(ID.MajorID.EMPEROR, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)
	set_charges(ID.MajorID.EMPEROR, Stats.major_emperor)
	
func get_emperor() -> int:
	var output: int = 0
	match get_state(ID.MajorID.EMPEROR):
		ID.CardState.POSITIVE:
			output = Stats.major_emperor
		ID.CardState.NEGATIVE:
			output = -Stats.major_emperor
		_:
			output = 0
	return output
#endregion
#region = "Lovers"
func draw_lovers(flipped: bool) -> void:
	if flipped:
		var cards: Array[Card] = get_duplicates(GM.deck_manager.active_deck)
		for num in Stats.major_lovers:
			if cards.size() <= 0:
				break
			GM.deck_manager.remove_card(ID.Suits.NONE, cards.pop_at(randi() % cards.size()))
	else:
		var deck: Array[Card] = GM.deck_manager.get_deck_list()
		for num in Stats.major_lovers:
			GM.deck_manager.add_card(deck.pop_at(randi() % deck.size()).card_id_num)
#endregion
#region = "Chariot"
func draw_chariot(flipped: bool) -> void:
	set_state(ID.MajorID.CHARIOT, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)
	chariot_tracker.clear()
	
func update_chariot(value: int) -> void:
	if value == 0 || !check_active(ID.MajorID.CHARIOT):
		return
	if chariot_tracker.size() == 0 || abs(value) >= chariot_tracker[chariot_tracker.size()-1]:
		chariot_tracker.append(abs(value))
	else:
		trigger_chariot()
	set_charges(ID.MajorID.CHARIOT, get_chariot_value())
	
func trigger_chariot() -> void:
	var output: int = 0
	match get_state(ID.MajorID.CHARIOT):
		ID.CardState.POSITIVE:
			output = get_chariot_value()
		ID.CardState.NEGATIVE:
			output = -get_chariot_value()
		_:
			pass
	Events.emit_update_currency(output)
	set_state(ID.MajorID.CHARIOT, ID.CardState.INACTIVE)
	
func get_chariot_value() -> int:
	var output = chariot_tracker.reduce(func(accum,number): return accum * number, 0)
	return output
#endregion
#region = "Hermit"
func draw_hermit(_flipped: bool) -> void:
	var hermit_output: int = (
		 Stats.clairvoyance 
		 if get_duplicates(GM.deck_manager.active_deck).size() <= 0 
		 else -roundi(float(Stats.clairvoyance) / 2)
							 )
	Events.emit_update_currency(hermit_output)
#endregion
#region = "Wheel of Fortune"
func draw_wheel_of_fortune(flipped: bool) -> void:
	Events.emit_choose_suit()
	wheel_checked = false
	wheel_suit = await Events.chosen_suit
	set_state(ID.MajorID.WHEEL_OF_FORTUNE, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)
		
func trigger_wheel_of_fortune(suit: ID.Suits) -> void:
	if wheel_checked == false && wheel_suit == suit:
		add_charges(ID.MajorID.WHEEL_OF_FORTUNE, Stats.major_wheel_charges)
		Events.emit_particle(ID.ParticleType.SUCCESS)
	else:
		set_state(ID.MajorID.WHEEL_OF_FORTUNE, ID.CardState.INACTIVE)
		Events.emit_particle(ID.ParticleType.FAILURE)
	wheel_checked = true
	
func wheel_modifier(value: int) -> int:
	var output: int
	if !check_active(ID.MajorID.WHEEL_OF_FORTUNE) || value == 0:
		output =value
	else:
		output = (value * Stats.major_wheel_mult
			if get_state(ID.MajorID.WHEEL_OF_FORTUNE) == ID.CardState.POSITIVE 
			else int(float(value) / float(Stats.major_wheel_mult)))
		remove_charges(ID.MajorID.WHEEL_OF_FORTUNE, 1)
	if get_charges(ID.MajorID.WHEEL_OF_FORTUNE) <= 0:
		set_state(ID.MajorID.WHEEL_OF_FORTUNE, ID.CardState.INACTIVE)
	return output

#endregion

#region = "Hanged Man"
func draw_hanged_man(flipped: bool) -> void:
	Events.emit_hanged_man_choice()
	var gamble_percent: float = await Events.hanged_man_chosen
	if gamble_percent <= 0.0:
		return
	var chosen_gamble = Stats.clairvoyance * gamble_percent
	if flipped:
		Events.emit_update_currency(-chosen_gamble)
		Events.emit_particle(ID.ParticleType.FAILURE)
	else:
		Events.emit_update_currency((chosen_gamble*Stats.major_hanged_man)-chosen_gamble)
		Events.emit_particle(ID.ParticleType.SUCCESS)

#endregion
#region = "Temperance"
func draw_temperance(flipped: bool) -> void:
	set_state(ID.MajorID.TEMPERANCE, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)
	set_charges(ID.MajorID.TEMPERANCE, Stats.major_temperance)
	
func trigger_temperance(value: int) -> int:
	if get_state(ID.MajorID.TEMPERANCE) == ID.CardState.POSITIVE:
		return value if value >= Stats.major_temperance else Stats.major_temperance
	elif get_state(ID.MajorID.TEMPERANCE) == ID.CardState.NEGATIVE:
		return value if value <= Stats.major_temperance else Stats.major_temperance
	return value

#endregion
#region = "Devil"
func draw_devil(flipped: bool) -> void:
	set_state(ID.MajorID.DEVIL, ID.CardState.NEGATIVE if flipped else ID.CardState.POSITIVE)
	add_charges(ID.MajorID.DEVIL, Stats.major_devil)
	if GM.deck_manager.active_deck.size() >= 3:
		GM.deck_manager.add_card(516)
	
func devil_forced() -> bool:
	var state: ID.CardState = get_state(ID.MajorID.DEVIL)
	match state:
		ID.CardState.NEGATIVE:
			return true
		_:
			return false
			
func trigger_devil() -> void:
	remove_charges(ID.MajorID.DEVIL, 1)
	if get_charges(ID.MajorID.DEVIL) <= 0:
		set_state(ID.MajorID.DEVIL, ID.CardState.INACTIVE)
#endregion
#region = "Tower"
func draw_tower(flipped: bool) -> void:
	if check_active(ID.MajorID.TOWER):
		set_state(ID.MajorID.TOWER, ID.CardState.POSITIVE if get_state(ID.MajorID.TOWER) == ID.CardState.NEGATIVE else ID.CardState.NEGATIVE)
	else:
		set_state(ID.MajorID.TOWER, ID.CardState.POSITIVE if !flipped else ID.CardState.NEGATIVE)
		GM.deck_manager.add_card(517)

func trigger_tower(value: int) -> int:
	var output: int = 0
	match get_state(ID.MajorID.TOWER):
		ID.CardState.POSITIVE:
			output = value * Stats.major_tower
		ID.CardState.NEGATIVE:
			output = int(float(value) / float(Stats.major_tower))
		_:
			output = value
	return output
#endregion
#region = "Star"
func draw_star() -> void:
	var moon_state: ID.CardState = get_state(ID.MajorID.MOON)
	add_charges(ID.MajorID.STAR, 
				Stats.major_star * int(pow(float(Stats.major_moon), float(moons_drawn))) 
				if moons_drawn > 0 
				else Stats.major_star
				)
	set_state(ID.MajorID.STAR, ID.CardState.POSITIVE if moon_state != ID.CardState.NEGATIVE else ID.CardState.NEGATIVE)
	
func check_star(flipped:bool) -> bool:
	var star_active: ID.CardState = get_state(ID.MajorID.STAR)
	if !star_active || (flipped && !stars_work_on_bad):
		return false
	return true

func trigger_star(value: int) -> int:
	return value + get_charges(ID.MajorID.STAR)
#endregion
#region = "Moon"
func draw_moon(flipped: bool) -> void:
	if flipped:
		stars_work_on_bad = true
	else:
		moons_drawn += 1
		set_charges(ID.MajorID.MOON, moons_drawn)
	set_state(ID.MajorID.MOON, ID.CardState.POSITIVE if !flipped else ID.CardState.NEGATIVE)
	
#endregion
#region = "Sun"
func draw_sun(flipped: bool) -> void:
	if flipped:
		GM.deck_manager.remove_all_copies(518)
		GM.deck_manager.remove_all_copies(519)
	else:
		for x in Stats.major_sun_star:
			GM.deck_manager.add_card(518)
		for x in Stats.major_sun_moon:
			GM.deck_manager.add_card(519)
#endregion
#region = "Judgement"
func draw_judgement(flipped: bool) -> void:
	if flipped:
		add_charges(ID.MajorID.JUDGEMENT, 1)
	else:
		remove_charges(ID.MajorID.JUDGEMENT, 1)
	var charges: int = get_charges(ID.MajorID.JUDGEMENT)
	set_state(ID.MajorID.JUDGEMENT, ID.CardState.POSITIVE if charges > 0 else ID.CardState.NEGATIVE if charges <= 0 else ID.CardState.INACTIVE)

func judgement_modifier(value: int) -> int:
	var charges: int = get_charges(ID.MajorID.JUDGEMENT)
	var output: int = 0
	match get_state(ID.MajorID.JUDGEMENT):
		ID.CardState.POSITIVE:
			output = value * (charges * Stats.major_judgement)
		ID.CardState.NEGATIVE:
			output = int(float(value) / float(charges * Stats.major_judgement))
		_:
			output = value
	return output
#endregion = "Judgement"

#region = "tools"
func check_active(id: ID.MajorID) -> bool:
	return _major_states[id][0] == ID.CardState.POSITIVE || _major_states[id][0] == ID.CardState.NEGATIVE
	
func get_state(id: ID.MajorID) -> ID.CardState:
	return _major_states[id][0] if _major_states.keys().has(id) else ID.CardState.UNKNOWN
	
func set_state(id: ID.MajorID, state: ID.CardState) -> void:
	_major_states[id][0] = state
	
func set_charges(id: ID.MajorID, charges: int) -> void:
	_major_states[id][1] = charges

func add_charges(id: ID.MajorID, charges: int) -> void:
	_major_states[id][1] += charges

func remove_charges(id: ID.MajorID, charges: int) -> void:
	_major_states[id][1] -= charges

func get_charges(id: ID.MajorID) -> int:
	return _major_states[id][1]

func get_display() -> Dictionary:
	return _major_states
	
func get_duplicates(cards: Array[Card]) -> Array[Card]:
	var originals: Array[Card]
	var duplicates: Array[Card] = []
	for card in cards:
		if !originals.has(card):
			originals.append(card)
		else:
			duplicates.append(card)
	return duplicates
#endregion