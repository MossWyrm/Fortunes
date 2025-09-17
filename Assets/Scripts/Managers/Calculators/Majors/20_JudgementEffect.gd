extends MajorEffectBase
class_name JudgementEffect

"""
=== Judgement ===
The ultimate conductor of Major Arcana harmony. Judgement evaluates the diversity of Major Arcana 
drawn this shuffle and exponentially amplifies ALL other major effects.
When drawn:
- If upright: +1 to judgements_drawn
- If reversed: -1 to judgements_drawn (can go negative for interference)
- Tracks unique major arcana drawn this shuffle for diversity bonus
- Formula: unique_majors ^ (judgement_stat * |judgements_drawn|)
- Upright: Amplifies other major effects by this power
- Reversed: Creates interference - divides other major effects by this power
Always triggers a major card animation representing harmony or chaos.
"""
var judgements_drawn: int = 0
var unique_majors_drawn: Dictionary = {}  # major_id -> times_seen

func apply(_card: Card, flipped: bool) -> int:
	if flipped:
		judgements_drawn -= 1  # Can go negative for interference
	else:
		judgements_drawn += 1
	
	# Update card state based on draws
	if judgements_drawn > 0:
		card_state = DataStructures.CardState.POSITIVE
	elif judgements_drawn < 0:
		card_state = DataStructures.CardState.NEGATIVE  # Interference mode
	else:
		card_state = DataStructures.CardState.INACTIVE
	
	DebugManager.print_card_effects(str("[JudgementEffect] Judgement drawn! Count: ", judgements_drawn, 
		  ", Unique majors drawn: ", unique_majors_drawn.size(), 
		  ", Amplification: ", get_amplification_power(), 
		  ", Card state: ", card_state), DebugManager.DebugLevel.INFO)
	
	# Detailed debug output for major diversity tracking
	DebugManager.print_card_effects(str("[JudgementEffect] Major diversity details: ", unique_majors_drawn), 
		  DebugManager.DebugLevel.VERBOSE)
	DebugManager.print_card_effects(str("[JudgementEffect] Formula: ", unique_majors_drawn.size(), "^(", 
		  game_state.stats.major_stats.judgement, " * ", abs(judgements_drawn), ") = ", 
		  get_amplification_power()), DebugManager.DebugLevel.VERBOSE)
	
	return 0

func update_uniques(card: Card) -> void:
	# Check if this is a major arcana card
	if card.suit != DataStructures.SuitType.MAJOR:
		return

	if not unique_majors_drawn.has(card.id):
		unique_majors_drawn[card.id] = 0
	unique_majors_drawn[card.id] += 1

	DebugManager.print_card_effects(str("[JudgementEffect] Tracking major: %s, Times drawn: %s, Total unique: %s"
		%[card.id, unique_majors_drawn[card.id], unique_majors_drawn.size()]), 
		DebugManager.DebugLevel.VERBOSE)

func get_value(_value: int = 0) -> int:
	# Return judgements drawn for display purposes
	return judgements_drawn

func modify_card_value(value: int) -> int:
	# Judgement amplifies the input value based on major arcana diversity and harmony
	if card_state == DataStructures.CardState.INACTIVE or judgements_drawn == 0:
		DebugManager.print_card_effects(str("[JudgementEffect] Inactive - no amplification applied to: ", value), 
			  DebugManager.DebugLevel.VERBOSE)
		return value
	
	var amplification = get_amplification_power()
	var original_value = value
	var result: int
	
	# Apply amplification or interference
	if judgements_drawn > 0:
		# Positive: Harmony amplification
		result = int(value * amplification)
		DebugManager.print_card_effects(str("[JudgementEffect] HARMONY: ", original_value, " × ", 
			  amplification, " = ", result), DebugManager.DebugLevel.INFO)
	else:
		# Negative: Interference - divide by amplification
		result = max(1, int(float(value) / amplification))  # Don't go below 1
		DebugManager.print_card_effects(str("[JudgementEffect] INTERFERENCE: ", original_value, " ÷ ", 
			  amplification, " = ", result), DebugManager.DebugLevel.INFO)
	
	return result

func get_amplification_power() -> float:
	var unique_majors = unique_majors_drawn.size()
	if unique_majors == 0 or judgements_drawn == 0:
		return 1.0
	
	var judgement_stat = game_state.stats.major_stats.judgement

	var exponent = judgement_stat * abs(judgements_drawn)
	var base_power = pow(unique_majors, exponent)
	
	if judgements_drawn > 0:
		# Positive: Harmony amplification based on major diversity
		return base_power
	else:
		# Negative: Interference - the more diverse majors, the worse it gets
		return 1.0 / base_power

func get_interference_factor() -> float:
	# For when other systems need to know if there's interference
	if judgements_drawn < 0:
		return get_amplification_power()  # This will be < 1.0
	return 1.0

func reset() -> void:
	judgements_drawn = 0
	unique_majors_drawn.clear()
	card_state = DataStructures.CardState.INACTIVE

func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"judgements_drawn": judgements_drawn,
		"unique_majors_drawn": unique_majors_drawn.duplicate()
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("judgements_drawn"):
		judgements_drawn = backup["judgements_drawn"]
	if backup.has("unique_majors_drawn"):
		unique_majors_drawn = backup["unique_majors_drawn"].duplicate()
	# Legacy support for old saves
	elif backup.has("judgement_charges"):
		judgements_drawn = backup["judgement_charges"]
	elif backup.has("powers_of_ten"):
		judgements_drawn = backup["powers_of_ten"]