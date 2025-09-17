extends MajorEffectBase
class_name StrengthEffect

"""
=== Strength ===
When drawn, sets the Strength card_state to POSITIVE (upright) or NEGATIVE (reversed).
Builds endurance through persistence - each card drawn adds to a growing bonus/penalty 
that affects all future cards until the next shuffle.

Upright: Each card drawn adds +1 to the endurance bonus for all subsequent cards
Reversed: Each card drawn adds -1 to the endurance penalty for all subsequent cards

The effect grows stronger the more cards you draw, rewarding sustained play.
"""

var endurance_bonus: int = 0

func apply(_card: Card, flipped: bool) -> int:
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    card_state = set_state
    endurance_bonus = 0  # Reset bonus when Strength is drawn
    
    DebugManager.print_card_effects(str("[StrengthEffect] STRENGTH AWAKENS - ", 
          "Weakening endurance" if flipped else "Building endurance", 
          ", Bonus reset to 0"), DebugManager.DebugLevel.INFO)
    
    return 0

func update(_value: int) -> void:
    if card_state == DataStructures.CardState.INACTIVE:
        return
    
    var old_bonus = endurance_bonus
    var strength_stat = GameManager.game_state.stats.major_stats.strength
    
    # Each card drawn increases the endurance bonus/penalty
    match card_state:
        DataStructures.CardState.POSITIVE:
            endurance_bonus += strength_stat
            DebugManager.print_card_effects(str("[StrengthEffect] ENDURANCE BUILDS - Bonus: ", 
                  old_bonus, " → ", endurance_bonus, " (+", strength_stat, ")"), DebugManager.DebugLevel.VERBOSE)
        DataStructures.CardState.NEGATIVE:
            endurance_bonus -= strength_stat
            DebugManager.print_card_effects(str("[StrengthEffect] WEAKNESS GROWS - Penalty: ", 
                  old_bonus, " → ", endurance_bonus, " (-", strength_stat, ")"), DebugManager.DebugLevel.VERBOSE)

func get_value(_additional_val: int = 0) -> int:
    # Return current endurance bonus for display purposes
    return endurance_bonus

func modify_card_value(input_value: int) -> int:
    if card_state == DataStructures.CardState.INACTIVE:
        DebugManager.print_card_effects(str("[StrengthEffect] INACTIVE - No modification applied."), 
              DebugManager.DebugLevel.VERBOSE)
        return input_value
    DebugManager.print_card_effects(str("[StrengthEffect] APPLYING ENDURANCE - ", input_value, 
          ("+ " if endurance_bonus >= 0 else "- "), abs(endurance_bonus), 
          " (bonus) = ", input_value + endurance_bonus), DebugManager.DebugLevel.INFO)
    # Apply the accumulated endurance bonus to the card
    return input_value + endurance_bonus

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE
    endurance_bonus = 0

func get_state_backup() -> Dictionary:
    return {
        "card_state": card_state,
        "endurance_bonus": endurance_bonus
    }

func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("card_state"):
        card_state = backup["card_state"]
    if backup.has("endurance_bonus"):
        endurance_bonus = backup["endurance_bonus"]
