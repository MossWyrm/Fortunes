extends MajorEffectBase
class_name JusticeEffect

"""
=== Justice (Karmic Ledger) ===
Justice operates in two phases to balance cosmic debts:

Phase 1 (First Justice): 
  - Adds a second Justice to the deck
  - Begins tracking karma based on fortune magnitude

Phase 2 (Second Justice): 
  - Settles karmic debts based on recent performance
  - Uses rolling 8-card average for calculations

Karma System:
  - Tracks absolute magnitude of fortune (positive and negative both count)
  - Above average magnitude = karma debt (you owe the universe)
  - Below average magnitude = karma credit (universe owes you)

Settlement Calculation:
  - Upright: Fair settlement proportional to karma and average
  - Reversed: Harsh settlement (extra penalty) or denial of credit

Always triggers a major card animation.
"""

# Configuration Constants
const JUSTICE_ID = 512
const KARMA_WINDOW_SIZE = 8
const MIN_CARDS_FOR_KARMA = 3
const KARMA_SCALE_FACTOR = 15.0
const SETTLEMENT_SCALE_FACTOR = 10.0
const REVERSED_PENALTY_MULTIPLIER = 1.5
const DISPLAY_SCALE_FACTOR = 10.0

# Karma States
var karma_tracking_active: bool = false
var karma_balance: float = 0.0
var recent_card_values: Array[int] = []
var justice_in_deck: bool = false

#region Public Interface
func apply(_card: Card, flipped: bool) -> int:
	if not justice_in_deck:
		# First Justice - start the karma cycle
		DebugManager.print_card_effects("[JusticeEffect] FIRST JUSTICE - Beginning karma tracking cycle", 
			  DebugManager.DebugLevel.INFO)
		_start_karma_tracking()
		game_state.deck_manager.add_card_by_id(JUSTICE_ID)
		justice_in_deck = true
		card_state = DataStructures.CardState.UNKNOWN
		DebugManager.print_card_effects("[JusticeEffect] Added second Justice card to deck, karma tracking active", 
			  DebugManager.DebugLevel.VERBOSE)
		return 0
	else:
		# Second Justice - settle the karmic debt
		DebugManager.print_card_effects(str("[JusticeEffect] SECOND JUSTICE - Settling karma (", 
			  "HARSH" if flipped else "FAIR", " judgment)"), DebugManager.DebugLevel.INFO)
		_settle_karma(flipped)
		return 0

func update_karma(card: Card, final_value: int) -> void:
	if karma_tracking_active:
		DebugManager.print_card_effects(str("[JusticeEffect] Tracking karma for card value: ", final_value, 
			  ", Balance before: ", karma_balance), DebugManager.DebugLevel.VERBOSE)
		_track_karma(final_value, card)

func shuffle(safely: bool = false) -> void:
	if safely:
		# Justice will wait until next draw to settle karma
		return
	
	if karma_tracking_active:
		# Justice must be served even during shuffle!
		if karma_balance != 0.0:
			_settle_karma(false)  # Assume upright for shuffle justice
	reset()

func get_value(_additional_val: int = 0) -> int:
	if karma_tracking_active:
		return int(karma_balance * DISPLAY_SCALE_FACTOR)
	return 0

func reset() -> void:
	card_state = DataStructures.CardState.INACTIVE
	_stop_karma_tracking()

#endregion

#region State Management
func get_state_backup() -> Dictionary:
	return {
		"card_state": card_state,
		"karma_tracking_active": karma_tracking_active,
		"karma_balance": karma_balance,
		"recent_card_values": recent_card_values.duplicate(),
		"justice_in_deck": justice_in_deck
	}

func restore_state_backup(backup: Dictionary) -> void:
	if backup.has("card_state"):
		card_state = backup["card_state"]
	if backup.has("karma_tracking_active"):
		karma_tracking_active = backup["karma_tracking_active"]
	if backup.has("karma_balance"):
		karma_balance = backup["karma_balance"]
	if backup.has("recent_card_values"):
		recent_card_values = backup["recent_card_values"].duplicate()
	if backup.has("justice_in_deck"):
		justice_in_deck = backup["justice_in_deck"]
#endregion

#region Private Helpers
func _start_karma_tracking() -> void:
	karma_tracking_active = true
	karma_balance = 0.0
	recent_card_values.clear()
	DebugManager.print_card_effects("[JusticeEffect] Karma tracking initialized - balance reset to 0", 
		  DebugManager.DebugLevel.VERBOSE)

func _stop_karma_tracking() -> void:
	karma_tracking_active = false
	justice_in_deck = false
	karma_balance = 0.0
	recent_card_values.clear()

func _track_karma(final_value: int, _card: Card) -> void:
	if not karma_tracking_active:
		return
	
	# Add to recent values for rolling average calculation
	recent_card_values.append(final_value)
	if recent_card_values.size() > KARMA_WINDOW_SIZE:
		recent_card_values.pop_front()
	
	# Only calculate karma after we have enough data points
	if recent_card_values.size() >= MIN_CARDS_FOR_KARMA:
		var recent_average = _get_recent_average()
		# Use the magnitude (absolute value) of current card vs average magnitude for karma calculation
		var current_magnitude = abs(final_value)
		var karma_change = (current_magnitude - recent_average) / KARMA_SCALE_FACTOR
		karma_balance += karma_change
		
		DebugManager.print_card_effects("[JusticeEffect] Karma updated: magnitude=%d, avg_magnitude=%.1f, change=%.2f, new_balance=%.2f" % [current_magnitude, recent_average, karma_change, karma_balance], 
			  DebugManager.DebugLevel.VERBOSE)
	if karma_balance < 0.0:
		card_state = DataStructures.CardState.POSITIVE
	elif karma_balance > 0.0:
		card_state = DataStructures.CardState.NEGATIVE
	else:
		card_state = DataStructures.CardState.UNKNOWN

func _settle_karma(flipped: bool) -> void:
	if karma_balance == 0.0:
		_stop_karma_tracking()
		return

	var current_average = _get_recent_average()
	var base_settlement = karma_balance * (current_average / SETTLEMENT_SCALE_FACTOR)
	
	# Apply justice stat as settlement value multiplier
	var justice_multiplier = game_state.stats.major_stats.justice
	var enhanced_settlement = base_settlement * justice_multiplier
	var final_settlement = 0
	
	DebugManager.print_card_effects(str("[JusticeEffect] Settlement calculation - base: ", base_settlement, 
		  ", justice multiplier: ", justice_multiplier, ", enhanced: ", enhanced_settlement), 
		  DebugManager.DebugLevel.VERBOSE)
	
	if flipped:
		# Reversed Justice: Harsh treatment
		if karma_balance > 0:
			# You owe karma - Justice takes extra penalty
			final_settlement = int(enhanced_settlement * REVERSED_PENALTY_MULTIPLIER)
		else:
			# Universe owes you - Justice gives nothing (unfair denial)
			final_settlement = 0
			DebugManager.print_card_effects("[JusticeEffect] Reversed Justice denies positive karma credit", 
				  DebugManager.DebugLevel.INFO)
	else:
		# Upright Justice: Fair treatment with enhanced value
		final_settlement = int(enhanced_settlement)
	
	# Apply settlement via EventBus (majors return 0, use EventBus for currency)
	if final_settlement != 0:
		# Positive karma_balance = debt = LOSE currency
		# Negative karma_balance = credit = GAIN currency
		DebugManager.print_card_effects(str("[JusticeEffect] Karma settlement applied: ", -final_settlement, 
			  " clairvoyance (", "debt payment" if final_settlement > 0 else "credit reward", ")"), 
			  DebugManager.DebugLevel.INFO)
		EventBus.emit_currency_updated(-final_settlement, DataStructures.CurrencyType.CLAIRVOYANCE)
	
	_stop_karma_tracking()

func _get_recent_average() -> float:
	if recent_card_values.is_empty():
		return 0.0
	
	# Use absolute values for average calculation
	var abs_values = recent_card_values.map(func(val): return abs(val))
	var sum = abs_values.reduce(func(acc, val): return acc + val, 0)
	return float(sum) / float(abs_values.size())
#endregion