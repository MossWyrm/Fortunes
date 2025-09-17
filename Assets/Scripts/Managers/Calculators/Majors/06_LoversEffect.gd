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
    var active_deck = game_state.deck_manager.active_deck
    
    DebugManager.print_card_effects(str("[LoversEffect] THE LOVERS - ", 
          "Breaking bonds (removing duplicates)" if flipped else "Creating bonds (adding cards)", 
          ", Target count: ", count), DebugManager.DebugLevel.INFO)
    
    if flipped:
        # Reversed: Remove random duplicate cards from the deck
        var duplicates = _get_duplicates(active_deck)
        DebugManager.print_card_effects(str("[LoversEffect] Found ", duplicates.size(), " duplicate cards"), 
              DebugManager.DebugLevel.VERBOSE)
        
        var removed_count = 0
        for i in range(count):
            if duplicates.size() <= 0:
                break
            var card_to_remove = duplicates.pop_at(randi() % duplicates.size())
            game_state.deck_manager.remove_card_by_id(card_to_remove.id)
            removed_count += 1
            DebugManager.print_card_effects(str("[LoversEffect] Removed duplicate: ", card_to_remove.id), 
                  DebugManager.DebugLevel.VERBOSE)
        
        DebugManager.print_card_effects(str("[LoversEffect] Bonds broken - removed ", removed_count, " duplicates"), 
              DebugManager.DebugLevel.INFO)
    else:
        # Upright: Add random cards to the deck
        var added_count = 0
        for i in range(count):
            if active_deck.size() <= 0:
                break
            var card_to_add_by_id = active_deck.cards[randi() % active_deck.size()].id
            game_state.deck_manager.add_card_by_id(card_to_add_by_id)
            added_count += 1
            DebugManager.print_card_effects(str("[LoversEffect] Added copy of card: ", card_to_add_by_id), 
                  DebugManager.DebugLevel.VERBOSE)
        
        DebugManager.print_card_effects(str("[LoversEffect] Bonds formed - added ", added_count, " card copies"), 
              DebugManager.DebugLevel.INFO)
    return 0

# Helper to find duplicate cards in a deck
func _get_duplicates(deck: Deck) -> Array[Card]:
    var seen = {}
    var duplicates: Array[Card] = []
    for card in deck.cards:
        if card.id in seen:
            duplicates.append(card)
        else:
            seen[card.id] = true
    return duplicates
