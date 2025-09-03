extends MajorEffectBase
class_name HierophantEffect

"""
=== The Hierophant ===
# TODO: CREATE HIEROPHANT EFFECT
When drawn, sets the Hierophant card_state to POSITIVE (upright) or NEGATIVE (reversed).
Stores the next card's suit for later comparison (bonus/penalty if next card matches/differs).
Always triggers a major card animation.
"""

var next_card_suit = null

func apply(_card: Card, flipped: bool) -> int:
    # Set the Hierophant card_state using the generic major card_state system and shared enum
    var set_state = DataStructures.CardState.NEGATIVE if flipped else DataStructures.CardState.POSITIVE
    card_state = set_state
    # Store the next card's suit for later use
    var next_card = game_state.deck_manager.peek_card(0)
    if next_card:
        next_card_suit = next_card.suit
    
    return 0

# Optionally, add a method to check the stored suit for bonus/penalty logic
func get_next_card_suit() -> int:
    return next_card_suit

func reset() -> void:
    card_state = DataStructures.CardState.INACTIVE
    next_card_suit = null