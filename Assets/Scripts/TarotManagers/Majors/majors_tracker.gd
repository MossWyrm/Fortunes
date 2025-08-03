extends suit_tracker
class_name majors_tracker

var _major_states: Dictionary = {}

var empress_collection: Array[int] = []
var chariot_tracker: Array[int] = []
var wheel_suit: DataStructures.SuitType = DataStructures.SuitType.NONE
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
		_major_states[value] = [DataStructures.CardState.INACTIVE]
	for major_id in requires_initialization:
		_major_states[major_id].append(0)

func update(_value, _flipped = false) -> void:
	return

func shuffle(safely: bool = false) -> void:
	if safely:
		return
	for key in _major_states.keys():
		set_state(key, DataStructures.CardState.INACTIVE) 
		if _major_states[key].size() >1:
			set_charges(key, 0)
	empress_collection.clear()
	stars_work_on_bad = false 
	moons_drawn = 0
	wheel_suit = DataStructures.SuitType.NONE
	
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
	set_state(ID.MajorID.EMPRESS, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)

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
		DataStructures.CardState.POSITIVE:
			multiplier = 1
		DataStructures.CardState.NEGATIVE:
			multiplier = -1
		_:
			multiplier = 0
	# Sum the collection and apply the multiplier
	return empress_collection.reduce(func(accum, number): return accum + number, 0) * multiplier
#endregion
#region = "Emperor"
func draw_emperor(flipped: bool) -> void:
	set_state(ID.MajorID.EMPEROR, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
	set_charges(ID.MajorID.EMPEROR, Stats.major_emperor)
	
func get_emperor() -> int:
	var output: int = 0
	match get_state(ID.MajorID.EMPEROR):
		DataStructures.CardState.POSITIVE:
			output = Stats.major_emperor
		DataStructures.CardState.NEGATIVE:
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
			GM.deck_manager.remove_card(DataStructures.SuitType.NONE, cards.pop_at(randi() % cards.size()))
	else:
		var deck: Array[Card] = GM.deck_manager.get_deck_list()
		for num in Stats.major_lovers:
			GM.deck_manager.add_card(deck.pop_at(randi() % deck.size()).card_id_num)
#endregion
#region = "Chariot"
func draw_chariot(flipped: bool) -> void:
	set_state(ID.MajorID.CHARIOT, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
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
		DataStructures.CardState.POSITIVE:
			output = get_chariot_value()
		DataStructures.CardState.NEGATIVE:
			output = -get_chariot_value()
		_:
			pass
	Events.emit_update_currency(output)
	set_state(ID.MajorID.CHARIOT, DataStructures.CardState.INACTIVE)
	
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
	set_state(ID.MajorID.WHEEL_OF_FORTUNE, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
		
func trigger_wheel_of_fortune(suit: DataStructures.SuitType) -> void:
	if wheel_checked == false && wheel_suit == suit:
		add_charges(ID.MajorID.WHEEL_OF_FORTUNE, Stats.major_wheel_charges)
		Events.emit_particle(ID.ParticleType.SUCCESS)
	else:
		set_state(ID.MajorID.WHEEL_OF_FORTUNE, DataStructures.CardState.INACTIVE)
		Events.emit_particle(ID.ParticleType.FAILURE)
	wheel_checked = true
	
func wheel_modifier(value: int) -> int:
	var output: int
	if !check_active(ID.MajorID.WHEEL_OF_FORTUNE) || value == 0:
		output =value
	else:
		output = (value * Stats.major_wheel_mult
			if get_state(ID.MajorID.WHEEL_OF_FORTUNE) == DataStructures.CardState.POSITIVE 
			else int(float(value) / float(Stats.major_wheel_mult)))
		remove_charges(ID.MajorID.WHEEL_OF_FORTUNE, 1)
	if get_charges(ID.MajorID.WHEEL_OF_FORTUNE) <= 0:
		set_state(ID.MajorID.WHEEL_OF_FORTUNE, DataStructures.CardState.INACTIVE)
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
	set_state(ID.MajorID.TEMPERANCE, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
	set_charges(ID.MajorID.TEMPERANCE, Stats.major_temperance)
	
func trigger_temperance(value: int) -> int:
	if get_state(ID.MajorID.TEMPERANCE) == DataStructures.CardState.POSITIVE:
		return value if value >= Stats.major_temperance else Stats.major_temperance
	elif get_state(ID.MajorID.TEMPERANCE) == DataStructures.CardState.NEGATIVE:
		return value if value <= Stats.major_temperance else Stats.major_temperance
	return value

#endregion
#region = "Devil"
func draw_devil(flipped: bool) -> void:
	set_state(ID.MajorID.DEVIL, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
	add_charges(ID.MajorID.DEVIL, Stats.major_devil)
	if GM.deck_manager.active_deck.size() >= 3:
		GM.deck_manager.add_card(516)
	
func devil_forced() -> bool:
	var state: DataStructures.CardState = get_state(ID.MajorID.DEVIL)
	match state:
		DataStructures.CardState.NEGATIVE:
			return true
		_:
			return false
			
func trigger_devil() -> void:
	remove_charges(ID.MajorID.DEVIL, 1)
	if get_charges(ID.MajorID.DEVIL) <= 0:
		set_state(ID.MajorID.DEVIL, DataStructures.CardState.INACTIVE)
#endregion
#region = "Tower"
func draw_tower(flipped: bool) -> void:
	if check_active(ID.MajorID.TOWER):
		set_state(ID.MajorID.TOWER, DataStructures.CardState.POSITIVE if get_state(ID.MajorID.TOWER) == DataStructures.CardState.NEGATIVE else DataStructures.CardState.NEGATIVE)
	else:
		set_state(ID.MajorID.TOWER, DataStructures.CardState.POSITIVE if !flipped else DataStructures.CardState.NEGATIVE)
		GM.deck_manager.add_card(517)

func trigger_tower(value: int) -> int:
	var output: int = 0
	match get_state(ID.MajorID.TOWER):
		DataStructures.CardState.POSITIVE:
			output = value * Stats.major_tower
		DataStructures.CardState.NEGATIVE:
			output = int(float(value) / float(Stats.major_tower))
		_:
			output = value
	return output
#endregion
#region = "Star"
func draw_star() -> void:
	var moon_state: DataStructures.CardState = get_state(ID.MajorID.MOON)
	add_charges(ID.MajorID.STAR, 
				Stats.major_star * int(pow(float(Stats.major_moon), float(moons_drawn))) 
				if moons_drawn > 0 
				else Stats.major_star
				)
	set_state(ID.MajorID.STAR, DataStructures.CardState.POSITIVE if moon_state != DataStructures.CardState.NEGATIVE else DataStructures.CardState.NEGATIVE)
	
func check_star(flipped:bool) -> bool:
	var star_active: DataStructures.CardState = get_state(ID.MajorID.STAR)
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
	set_state(ID.MajorID.MOON, DataStructures.CardState.POSITIVE if !flipped else DataStructures.CardState.NEGATIVE)
	
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
	set_state(ID.MajorID.JUDGEMENT, DataStructures.CardState.POSITIVE if charges > 0 else DataStructures.CardState.NEGATIVE if charges <= 0 else DataStructures.CardState.INACTIVE)

func judgement_modifier(value: int) -> int:
	var charges: int = get_charges(ID.MajorID.JUDGEMENT)
	var output: int = 0
	match get_state(ID.MajorID.JUDGEMENT):
		DataStructures.CardState.POSITIVE:
			output = value * (charges * Stats.major_judgement)
		DataStructures.CardState.NEGATIVE:
			output = int(float(value) / float(charges * Stats.major_judgement))
		_:
			output = value
	return output
#endregion = "Judgement"

#region = "High Priestess"
func draw_high_priestess(flipped: bool) -> void:
	if flipped:
		# Inverted: Hide next X cards (store them as hidden)
		var hidden_cards = GM.deck_manager.peek_multiple_cards(Stats.major_high_priestess)
		# Store these cards as hidden until drawn
		# For now, just print them - you can implement a proper hidden card system later
		print("High Priestess (Inverted): Hidden cards: ", hidden_cards.size())
		for card in hidden_cards:
			print("  Hidden: ", card.card_id_num)
	else:
		# Upright: Reveal next X cards
		var revealed_cards = GM.deck_manager.peek_multiple_cards(Stats.major_high_priestess)
		# Show these cards to the player without drawing them
		print("High Priestess (Upright): Revealed cards: ", revealed_cards.size())
		for card in revealed_cards:
			print("  Revealed: ", card.card_id_num)
		# You can emit an event here to show the cards in the UI
		Events.emit_show_revealed_cards(revealed_cards)  # You'd need to implement this event
#endregion = "High Priestess"

#region = "Hierophant"
func draw_hierophant(flipped: bool) -> void:
	set_state(ID.MajorID.HEIROPHANT, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
	# Store the next card's suit to apply bonus/penalty to same/different suits
	var next_card = GM.deck_manager.peek_card(0)
	if next_card:
		# Store the suit for comparison when next card is drawn
		# This would need to be checked in the card calculation logic
		print("Hierophant: Next card suit is ", next_card.card_suit)
#endregion = "Hierophant"

#region = "Strength"
func draw_strength(flipped: bool) -> void:
	set_state(ID.MajorID.STRENGTH, DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE)
	set_charges(ID.MajorID.STRENGTH, Stats.major_strength)
#endregion = "Strength"

#region = "Justice"
func draw_justice(flipped: bool) -> void:
	if flipped:
		# Inverted: Unbalance deck by removing cards from most common suit
		var suit_counts = count_suits_in_deck()
		var most_common_suit = get_most_common_suit(suit_counts)
		for i in range(Stats.major_justice):
			GM.deck_manager.remove_card(most_common_suit)
	else:
		# Upright: Balance deck by ensuring equal numbers of each suit
		var suit_counts = count_suits_in_deck()
		var target_count = get_average_suit_count(suit_counts)
		for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
			var current_count = suit_counts.get(suit, 0)
			var cards_needed = target_count - current_count
			for i in range(cards_needed):
				GM.deck_manager.add_card_by_suit(suit)
#endregion = "Justice"

#region = "Death"
func draw_death(flipped: bool) -> void:
	if flipped:
		# Inverted: Remove all cards of a specific suit
		Events.emit_choose_suit()
		var suit = await Events.chosen_suit
		var cards_to_remove = GM.deck_manager.active_deck.filter(func(x: Card): return x.card_suit == suit)
		for card in cards_to_remove:
			GM.deck_manager.remove_card(DataStructures.SuitType.NONE, card.card_id_num)
	else:
		# Upright: Transform all cards to a random suit
		var random_suit = [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS][randi() % 4]
		# This would need to be implemented as a transformation effect
		print("Death: Transform all cards to suit ", random_suit)
#endregion = "Death"

#region = "Helper Methods"
func count_suits_in_deck() -> Dictionary:
	var counts = {}
	for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
		counts[suit] = 0
	for card in GM.deck_manager.active_deck:
		if card.card_suit in counts:
			counts[card.card_suit] += 1
	return counts

func get_most_common_suit(suit_counts: Dictionary) -> DataStructures.SuitType:
	var most_common = DataStructures.SuitType.CUPS
	var max_count = 0
	for suit in suit_counts.keys():
		if suit_counts[suit] > max_count:
			max_count = suit_counts[suit]
			most_common = suit
	return most_common

func get_average_suit_count(suit_counts: Dictionary) -> int:
	var total = 0
	var count = 0
	for suit_count in suit_counts.values():
		total += suit_count
		count += 1
	return total / count if count > 0 else 0
#endregion = "Helper Methods"

#region = "tools"
func check_active(id: ID.MajorID) -> bool:
	return _major_states[id][0] == DataStructures.CardState.POSITIVE || _major_states[id][0] == DataStructures.CardState.NEGATIVE
	
func get_state(id: ID.MajorID) -> DataStructures.CardState:
	return _major_states[id][0] if _major_states.keys().has(id) else DataStructures.CardState.UNKNOWN
	
func set_state(id: ID.MajorID, state: DataStructures.CardState) -> void:
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