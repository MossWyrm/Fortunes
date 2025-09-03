extends MajorEffectBase
class_name LoversEffect

"""
=== The Lovers ===
When drawn, if upright (not flipped), adds random cards to the deck (count = MajorStats.lovers).
If reversed (flipped), removes random duplicate cards from the deck (count = MajorStats.lovers).
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    
    var count = game_state.stats.major_stats.lovers
    if flipped:
        var cards = _get_duplicates(game_state.deck_manager.active_deck)
        for i in range(count):
            if cards.size() <= 0:
                break
            game_state.deck_manager.remove_card(DataStructures.SuitType.NONE, cards.pop_at(randi() % cards.size()))
    else:
        var deck = game_state.deck_manager.get_deck_list()
        for i in range(count):
            if deck.size() <= 0:
                break
            game_state.deck_manager.add_card(deck.pop_at(randi() % deck.size()).id)
    return 0

# Helper to find duplicate cards in a deck
func _get_duplicates(deck: Deck) -> Array[Card]:
    var seen = {}
    var duplicates = []
    for card in deck:
        if card.id in seen:
            duplicates.append(card)
        else:
            seen[card.id] = true
    return duplicates
