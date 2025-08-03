extends RefCounted
class_name EventBus

# Game lifecycle events
signal game_initialized
signal game_loaded
signal game_reset(reset_type: DataStructures.GameLayer)
signal game_paused(paused: bool)

# Card events
signal card_drawn(card: DataStructures.Card, flipped: bool)
signal card_calculated(card: DataStructures.Card, result: DataStructures.CardCalculationResult)
signal deck_shuffled(safely: bool)
signal deck_modified(operation: DataStructures.DeckOperation, card: DataStructures.Card)
signal clear_card

# UI events
signal currency_updated(amount: int, currency_type: DataStructures.CurrencyType)
signal suit_display_updated(suit: DataStructures.SuitType)
signal tooltip_requested(tooltip_data: DataStructures.TooltipData)
signal upgrade_purchased(upgrade: DataStructures.UpgradeData)
signal floating_text_requested(text: String)

# Audio events
signal sfx_requested(sfx_type: DataStructures.SFXType)
signal music_requested(music_type: DataStructures.MusicType)

# Choice events
signal suit_choice_requested(include_majors: bool)
signal suit_chosen(suit: DataStructures.SuitType)
signal skip_choice_requested
signal skip_chosen(skipped: bool)

# Animation events
signal card_animation_started(card: DataStructures.Card, animation_type: DataStructures.AnimationType)
signal card_animation_finished(card: DataStructures.Card)

# Emit methods
func emit_game_initialized():
	game_initialized.emit()

func emit_game_loaded():
	game_loaded.emit()

func emit_game_reset(reset_type: DataStructures.GameLayer):
	game_reset.emit(reset_type)

func emit_game_paused(paused: bool):
	game_paused.emit(paused)

func emit_card_drawn(card: DataStructures.Card, flipped: bool):
	card_drawn.emit(card, flipped)

func emit_card_calculated(card: DataStructures.Card, result: DataStructures.CardCalculationResult):
	card_calculated.emit(card, result)

func emit_deck_shuffled(safely: bool):
	deck_shuffled.emit(safely)

func emit_deck_modified(operation: DataStructures.DeckOperation, card: DataStructures.Card = null):
	deck_modified.emit(operation, card)

func emit_clear_card():
	clear_card.emit()

func emit_currency_updated(amount: int, currency_type: DataStructures.CurrencyType):
	currency_updated.emit(amount, currency_type)

func emit_suit_display_updated(suit: DataStructures.SuitType):
	suit_display_updated.emit(suit)

func emit_tooltip_requested(tooltip_data: DataStructures.TooltipData):
	tooltip_requested.emit(tooltip_data)

func emit_upgrade_purchased(upgrade: Upgrade):
	upgrade_purchased.emit(upgrade)

func emit_floating_text_requested(text: String):
	floating_text_requested.emit(text)

func emit_sfx_requested(sfx_type: DataStructures.SFXType):
	sfx_requested.emit(sfx_type)

func emit_music_requested(music_type: DataStructures.MusicType):
	music_requested.emit(music_type)

func emit_suit_choice_requested(include_majors: bool):
	suit_choice_requested.emit(include_majors)

func emit_suit_chosen(suit: DataStructures.SuitType):
	suit_chosen.emit(suit)

func emit_skip_choice_requested():
	skip_choice_requested.emit()

func emit_skip_chosen(skipped: bool):
	skip_chosen.emit(skipped)

func emit_card_animation_started(card: DataStructures.Card, animation_type: DataStructures.AnimationType):
	card_animation_started.emit(card, animation_type)

func emit_card_animation_finished(card: DataStructures.Card):
	card_animation_finished.emit(card) 