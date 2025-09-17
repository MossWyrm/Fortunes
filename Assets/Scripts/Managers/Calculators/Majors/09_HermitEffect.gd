extends MajorEffectBase
class_name HermitEffect

"""
=== The Hermit (Enlightened Path) ===
When drawn, sets the Hermit card_state to POSITIVE (upright) or NEGATIVE (reversed).
Tracks card types drawn since activation, building wisdom through experience.

Upright: Gains +2 bonus for each NEW unique card type discovered
Reversed: Gains +2 bonus for each REPEATED card type encountered

The accumulated wisdom bonus applies to all future cards until shuffle.
"""

var discovered_types: Dictionary = {}  # card_type -> times_seen
var wisdom_bonus: int = 0

func apply(_card: Card, flipped: bool) -> int:
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    card_state = set_state
    discovered_types.clear()
    wisdom_bonus = 0
    
    DebugManager.print_card_effects(str("[HermitEffect] HERMIT AWAKENS - ", 
          "Wisdom through repetition" if flipped else "Wisdom through discovery", 
          ", Tracking begins"), DebugManager.DebugLevel.INFO)
    
    return 0

func update_hermit(card: Card) -> void:
    var card_id = card.id  # Using card ID as the type identifier; adjust if needed
    if card_state == DataStructures.CardState.INACTIVE:
        return
    
    # Track how many times we've seen this card type
    if not discovered_types.has(card_id):
        discovered_types[card_id] = 0
    discovered_types[card_id] += 1
    
    var times_seen = discovered_types[card_id]
    var old_wisdom = wisdom_bonus
    
    match card_state:
        DataStructures.CardState.POSITIVE:
            # Upright: Bonus for NEW discoveries (first time seeing this type)
            if times_seen == 1:
                wisdom_bonus += 2
                DebugManager.print_card_effects(str("[HermitEffect] NEW DISCOVERY - Card type ", card_id, 
                      " first time seen, wisdom: ", old_wisdom, " → ", wisdom_bonus), DebugManager.DebugLevel.INFO)
            else:
                DebugManager.print_card_effects(str("[HermitEffect] Known path - Card type ", card_id, 
                      " seen ", times_seen, " times, no new wisdom"), DebugManager.DebugLevel.VERBOSE)
        DataStructures.CardState.NEGATIVE:
            # Reversed: Bonus for REPETITION (second+ time seeing this type)
            if times_seen > 1:
                wisdom_bonus += 2
                DebugManager.print_card_effects(str("[HermitEffect] DEEPER UNDERSTANDING - Card type ", card_id, 
                      " repeated (", times_seen, " times), wisdom: ", old_wisdom, " → ", wisdom_bonus), 
                      DebugManager.DebugLevel.INFO)
            else:
                DebugManager.print_card_effects(str("[HermitEffect] Surface knowledge - Card type ", card_id, 
                      " first time, no repetition wisdom yet"), DebugManager.DebugLevel.VERBOSE)

func get_value(_additional_val: int = 0) -> int:
    # Return wisdom bonus for display purposes
    return wisdom_bonus

func modify_card_value(input_value: int) -> int:
    if card_state == DataStructures.CardState.INACTIVE:
        return input_value
    
    # Apply accumulated wisdom bonus
    return input_value + wisdom_bonus

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE
    discovered_types.clear()
    wisdom_bonus = 0

func get_state_backup() -> Dictionary:
    return {
        "card_state": card_state,
        "discovered_types": discovered_types.duplicate(),
        "wisdom_bonus": wisdom_bonus
    }

func restore_state_backup(backup: Dictionary) -> void:
    if backup.has("card_state"):
        card_state = backup["card_state"]
    if backup.has("discovered_types"):
        discovered_types = backup["discovered_types"].duplicate()
    if backup.has("wisdom_bonus"):
        wisdom_bonus = backup["wisdom_bonus"]
