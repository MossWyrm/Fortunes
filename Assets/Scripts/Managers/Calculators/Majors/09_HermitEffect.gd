extends MajorEffectBase
class_name HermitEffect

"""
=== The Hermit ===
When drawn, if there are no duplicate cards in the deck, grants clairvoyance equal to current value.
If there are duplicates, removes half of current clairvoyance (rounded).
Always triggers a major card animation.
"""

func apply(_card: Card, _flipped: bool) -> int:
    var clairvoyance = 0
    var deck = game_state.deck_manager.active_deck
    if _get_duplicates(deck).size() <= 0:
        clairvoyance = game_state.stats.clairvoyance
    else:
        clairvoyance = -roundi(float(game_state.stats.clairvoyance) / 2)
    game_state.stats.clairvoyance += clairvoyance
    EventBus.emit_currency_updated(clairvoyance, DataStructures.CurrencyType.CLAIRVOYANCE)
    
    return 0

# Helper to find duplicate cards in a deck
func _get_duplicates(deck: Deck) -> Array:
    var seen = {}
    var duplicates = []
    for card in deck:
        if card.id in seen:
            duplicates.append(card)
        else:
            seen[card.id] = true
    return duplicates
