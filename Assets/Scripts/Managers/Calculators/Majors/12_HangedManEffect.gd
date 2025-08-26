extends MajorEffectBase
class_name HangedManEffect

"""
=== The Hanged Man ===
When drawn, prompts the player for a gamble percent. If upright, multiplies the gamble by the hanged man stat and adds it; if reversed, subtracts the gamble.
Always triggers a major card animation.
"""

func apply(_card: Card, flipped: bool) -> int:
    EventBus.emit_gamble_choice_requested()
    var gamble_percent: float = await EventBus.gamble_chosen
    if gamble_percent <= 0.0:
        return 0
    var chosen_gamble: int = roundi(game_state.stats.clairvoyance * gamble_percent)
    if flipped:
        game_state.stats.clairvoyance -= chosen_gamble
        EventBus.emit_currency_updated(-chosen_gamble, DataStructures.CurrencyType.CLAIRVOYANCE)
        EventBus.emit_request_vfx(DataStructures.VFXType.CARD_FAILURE)
    else:
        game_state.stats.clairvoyance += chosen_gamble * game_state.stats.major_stats.hanged_man - chosen_gamble
        EventBus.emit_currency_updated((chosen_gamble * game_state.stats.major_stats.hanged_man) - chosen_gamble, DataStructures.CurrencyType.CLAIRVOYANCE)
        EventBus.emit_request_vfx(DataStructures.VFXType.CARD_SUCCESS)
    EventBus.emit_major_card_animation_requested(flipped)
    return 0
