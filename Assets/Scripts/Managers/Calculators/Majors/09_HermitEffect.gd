extends MajorEffectBase
class_name HermitEffect

"""
=== The Hermit ===
When drawn, if there are no duplicate cards in the deck, grants clairvoyance equal to current value.
If there are duplicates, removes half of current clairvoyance (rounded).
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    var clairvoyance = 0
    var deck = game_state.deck_manager.active_deck
    if _get_duplicates(deck).size() <= 0:
        clairvoyance = game_state.stats.clairvoyance
    else:
        clairvoyance = -roundi(float(game_state.stats.clairvoyance) / 2)
    game_state.stats.clairvoyance += clairvoyance
    game_state.event_bus.emit_currency_updated(clairvoyance, DataStructures.CurrencyType.CLAIRVOYANCE)
    game_state.event_bus.emit_major_card_animation_requested(flipped)
    return 0

# Helper to find duplicate cards in a deck
func _get_duplicates(deck: Array) -> Array:
    var seen = {}
    var duplicates = []
    for card in deck:
        if card.card_id_num in seen:
            duplicates.append(card)
        else:
            seen[card.card_id_num] = true
    return duplicates
