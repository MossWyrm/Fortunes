extends MajorEffectBase
class_name JusticeEffect

"""
=== Justice ===
When drawn, if upright, balances the deck by ensuring equal numbers of each suit.
If reversed, removes cards from the most common suit.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    if flipped:
        var suit_counts = count_suits_in_deck(game_state.deck_manager)
        var most_common_suit = get_most_common_suit(suit_counts)
        for i in range(game_state.stats.major_stats.justice):
            game_state.deck_manager.remove_card(most_common_suit)
    else:
        var suit_counts = count_suits_in_deck(game_state.deck_manager)
        var target_count = get_average_suit_count(suit_counts)
        for suit in [DataStructures.SuitType.CUPS, DataStructures.SuitType.WANDS, DataStructures.SuitType.PENTACLES, DataStructures.SuitType.SWORDS]:
            var current_count = suit_counts.get(suit, 0)
            var cards_needed = target_count - current_count
            for i in range(cards_needed):
                game_state.deck_manager.add_card_by_suit(suit)
    EventBus.emit_major_card_animation_requested(flipped)
    return 0

# Helpers
func count_suits_in_deck(deck_manager) -> Dictionary:
    var counts = {}
    var deck = deck_manager.get_deck_list()
    for card in deck:
        counts[card.suit] = counts.get(card.suit, 0) + 1
    return counts

func get_most_common_suit(counts: Dictionary) -> int:
    var max_count = -1
    var max_suit = DataStructures.SuitType.CUPS
    for suit in counts.keys():
        if counts[suit] > max_count:
            max_count = counts[suit]
            max_suit = suit
    return max_suit

func get_average_suit_count(counts: Dictionary) -> int:
    var total = 0
    for v in counts.values():
        total += v
    return int(ceil(float(total) / 4.0))
