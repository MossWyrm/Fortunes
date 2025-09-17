extends MajorEffectBase
class_name DeathEffect

"""
=== Death (Renewal and Endings) ===
When drawn, triggers a complete state reset that clears accumulated effects and provides compensation.
Upright: "Positive Cleansing" - Removes all negative effects across all suits and major arcana
Reversed: "Negative Cleansing" - Removes all positive effects across all suits and major arcana

in both cases, rewards clairvoyance = (effects_cleared * recent_card_average * death_multiplier)

Compensation scales with game progression via recent card average and is upgradeable via death_multiplier.
Embodies Death's traditional meaning of endings leading to new beginnings.
"""

# Track recent card values for compensation calculation
var recent_card_values: Array[int] = []
var max_history_size: int = 20  # Track last 20 cards for average

func apply(_card: Card, flipped: bool) -> int:
    var clear_positive = flipped  # Reversed clears positive effects
    var clear_negative = not flipped  # Upright clears negative effects
    
    DebugManager.print_card_effects(str("[DeathEffect] DEATH ARRIVES - Clearing ", 
          "positive effects" if clear_positive else "negative effects"), DebugManager.DebugLevel.INFO)
    
    var effects_cleared: int = 0
    
    # Clear Major Arcana effects (returns count only)
    var major_effects_cleared = _clear_major_effects(clear_positive, clear_negative)
    effects_cleared += major_effects_cleared
    DebugManager.print_card_effects(str("[DeathEffect] Major effects cleared: ", major_effects_cleared), 
          DebugManager.DebugLevel.VERBOSE)
    
    # Clear Suit effects (returns count only)
    var suit_effects_cleared = _clear_suit_effects(clear_positive)
    effects_cleared += suit_effects_cleared
    DebugManager.print_card_effects(str("[DeathEffect] Suit effects cleared: ", suit_effects_cleared), 
          DebugManager.DebugLevel.VERBOSE)
    
    # Calculate compensation based on total effects cleared
    # Use recent average card magnitude and upgradeable Death multiplier
    var compensation = 0
    if effects_cleared > 0:
        var recent_average = _get_recent_card_average()
        var death_multiplier = game_state.stats.major_stats.death
        compensation = int(float(effects_cleared) * recent_average * float(death_multiplier))
        
        DebugManager.print_card_effects(str("[DeathEffect] REBIRTH COMPENSATION - Effects cleared: ", 
              effects_cleared, ", Avg card: ", recent_average, ", Multiplier: ", death_multiplier, 
              ", Compensation: ", compensation), DebugManager.DebugLevel.INFO)
    else:
        DebugManager.print_card_effects("[DeathEffect] No effects to clear - no compensation", 
              DebugManager.DebugLevel.VERBOSE)
    
    # Award compensation as clairvoyance
    if compensation > 0:
        EventBus.emit_currency_updated(compensation, DataStructures.CurrencyType.CLAIRVOYANCE)
    
    # Set Death as inactive (one-time effect)
    card_state = DataStructures.CardState.INACTIVE
    
    return 0

func _clear_major_effects(clear_positive: bool, clear_negative: bool) -> int:
    var effects_count: int = 0
    
    # Access all major effects through the major calculator
    var major_effects = major_calc.get_all_effects()
    
    for effect in major_effects:
        if effect == self:  # Don't clear Death itself
            continue
            
        var current_state = effect.card_state
        var should_clear = false
        
        # Determine if this effect should be cleared
        if clear_positive and current_state == DataStructures.CardState.POSITIVE:
            should_clear = true
        elif clear_negative and current_state == DataStructures.CardState.NEGATIVE:
            should_clear = true
        
        if should_clear:
            # Clear the effect and count it
            effect.card_state = DataStructures.CardState.INACTIVE
            effect.reset()
            effects_count += 1
    
    return effects_count

func _clear_suit_effects(clear_positive: bool) -> int:
    var effects_cleared: int = 0
    
    # Access all suit calculators through the card calculator
    var card_calc = game_state.card_calculator
    var calculators = [
        card_calc.cup_calculator,
        card_calc.wand_calculator, 
        card_calc.pentacle_calculator,
        card_calc.sword_calculator
    ]
    
    for calculator in calculators:
        if calculator and calculator.has_method("death_reset"):
            var count = calculator.death_reset(clear_positive)
            effects_cleared += count
    
    return effects_cleared

# Called by CardCalculator to update the running average of card values
func update_average(final_card_value: int) -> void:
    # Only track meaningful card values (absolute value >= 1)
    if abs(final_card_value) >= 1:
        recent_card_values.append(abs(final_card_value))
        
        # Keep only the most recent values
        while recent_card_values.size() > max_history_size:
            recent_card_values.remove_at(0)

func _get_recent_card_average() -> float:
    # Use actual tracked card values if we have them
    if recent_card_values.size() > 0:
        var total = 0
        for value in recent_card_values:
            total += value
        return float(total) / float(recent_card_values.size())
    
    # Fallback: use current clairvoyance as a rough indicator of card power
    # Higher clairvoyance usually means stronger cards have been played
    var clairvoyance = game_state.stats.clairvoyance
    if clairvoyance > 0:
        # Scale based on clairvoyance: higher clairvoyance = higher average card values
        return max(5.0, float(clairvoyance) / 10.0)  # Minimum 5, scales with progression
    
    # Default fallback for early game
    return 5.0

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE

func get_state_backup() -> Dictionary:
    return {
        "card_state": card_state,
        "recent_card_values": recent_card_values.duplicate(),
        "max_history_size": max_history_size
    }

func restore_state_backup(backup: Dictionary) -> void:
    card_state = backup.get("card_state", DataStructures.CardState.INACTIVE)
    recent_card_values = backup.get("recent_card_values", [])
    max_history_size = backup.get("max_history_size", 20)
