extends MajorEffectBase
class_name WheelOfFortuneEffect

"""
=== Wheel of Fortune ===
When drawn, prompts the player to choose a suit and grants charges for the next few cards.
If the first card drawn matches the chosen suit, those charges apply as a multiplier.
If it doesn't match, those charges apply as a divisor.
Always triggers a major card animation.
"""

var awaiting_check := false
var wheel_suit : DataStructures.SuitType = DataStructures.SuitType.NONE
var charges: int = 0

func apply(_card: Card, flipped: bool) -> int:
    EventBus.emit_suit_choice_requested(false)
    wheel_suit = await EventBus.suit_chosen
    charges = game_state.stats.major_stats.wheel_charges
    awaiting_check = true
    
    # Set initial state to neutral, will be determined on first card drawn
    card_state = DataStructures.CardState.UNKNOWN
    
    DebugManager.print_card_effects(str("[WheelOfFortuneEffect] WHEEL SPUN - Prediction: ", wheel_suit, 
          ", Charges: ", charges, ", Initial bias: ", 
          "Fortune" if not flipped else "Misfortune"), DebugManager.DebugLevel.INFO)
    
    return 0

# Called when a card is drawn to check for a match and apply bonus/penalty
func update(suit: int) -> void:
    # Only check the first card drawn after activation
    if not awaiting_check:
        return
    
    var suit_type = suit as DataStructures.SuitType
    if wheel_suit == suit_type:
        # Success: Keep positive state, show success VFX
        EventBus.emit_request_vfx(DataStructures.VFXType.CARD_SUCCESS)
        card_state = DataStructures.CardState.POSITIVE
        DebugManager.print_card_effects(str("[WheelOfFortuneEffect] FORTUNE FAVORS - Predicted ", 
              wheel_suit, " and drew ", suit_type, " - Success!"), DebugManager.DebugLevel.INFO)
    else:
        EventBus.emit_request_vfx(DataStructures.VFXType.CARD_FAILURE)
        card_state = DataStructures.CardState.NEGATIVE
        DebugManager.print_card_effects(str("[WheelOfFortuneEffect] WHEEL TURNS AGAINST - Predicted ", 
              wheel_suit, " but drew ", suit_type, " - Failure!"), DebugManager.DebugLevel.INFO)
    
    awaiting_check = false

func get_value(_value: int = 0) -> int:
    # Return charges for display purposes
    return charges

func modify_card_value(value: int) -> int:
    if charges <= 0 or card_state == DataStructures.CardState.INACTIVE:
        return value
    
    var output: int
    match card_state:
        DataStructures.CardState.POSITIVE:
            output = value * game_state.stats.major_stats.wheel_multiplier
        DataStructures.CardState.NEGATIVE:
            output = int(float(value) / float(game_state.stats.major_stats.wheel_multiplier))
        _:
            return value
    
    charges -= 1
    if charges <= 0:
        card_state = DataStructures.CardState.INACTIVE
    
    return output

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE
    awaiting_check = false
    wheel_suit = DataStructures.SuitType.NONE
    charges = 0

func active() -> bool:
    return charges > 0

# Returns a dictionary representing the effect's card_state for backup
func get_state_backup() -> Dictionary:
    return {
        "card_state": card_state,
        "awaiting_check": awaiting_check,
        "wheel_suit": wheel_suit,
        "charges": charges
    }

# Restores the effect's card_state from a backup dictionary
func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("card_state"):
        card_state = backup["card_state"]
    if backup.has("awaiting_check"):
        awaiting_check = backup["awaiting_check"]
    if backup.has("wheel_suit"):
        wheel_suit = backup["wheel_suit"]
    if backup.has("charges"):
        charges = backup["charges"]