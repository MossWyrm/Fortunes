extends Node
## Global EventBus - Available from project start as autoload
## Access via: EventBus.signal_name.connect() or EventBus.emit_signal_name()

# Game lifecycle events
signal game_initialized
signal game_loaded
signal game_reset(reset_type: DataStructures.GameLayer)
signal game_paused(paused: bool)
signal save_request
signal save_completed

# Card events
signal card_drawn(card: Card, flipped: bool)
signal card_calculated(card: Card, result: CardCalculationResult)
signal request_shuffle(safely: bool)
signal shuffle_completed(safely: bool)
signal deck_modified(operation: DataStructures.DeckOperation, card: Card)
signal clear_card
signal pack_complete

# UI events
signal currency_updated(amount: int, currency_type: DataStructures.CurrencyType)
signal request_buff_update(suit: DataStructures.SuitType, display_data: Dictionary)
signal tooltip_requested(object: Variant, layer: DataStructures.GameLayer, as_buff: bool)
signal upgrade_purchased(upgrade: UpgradeData)
signal floating_text_requested(number: float)
signal show_revealed_cards(cards: Array)

# Audio events
signal sfx_requested(sfx_type: DataStructures.SFXType)
signal music_requested(music_type: DataStructures.MusicType)

# Choice events
signal player_input_requested
signal player_input_received
signal suit_choice_requested(include_majors: bool)
signal suit_chosen(suit: DataStructures.SuitType)
signal skip_choice_requested
signal skip_chosen(skipped: bool)
signal gamble_choice_requested
signal gamble_chosen(gamble: float)
signal card_choice_requested(choices: Array)
signal card_chosen(card: Card)

# Animation events
signal card_animation_finished()
signal animation_requested(type: DataStructures.CardAnimationType, card: Card, flipped: bool)
signal animation_step_completed(step: String)
signal request_vfx(vfx_type: DataStructures.VFXType, animation_duration: float)
signal request_deck_change_animation(operation: DataStructures.DeckOperation, card: Card)

# Debug events
signal request_debug_menu()

#region Emit Wrappers

func emit_game_initialized():
	DebugManager.print_system_general("Emitting game_initialized signal")
	game_initialized.emit()
	DebugManager.print_system_general("EventBus: game_initialized signal emitted")

func emit_game_loaded():
	game_loaded.emit()

func emit_game_reset(reset_type: DataStructures.GameLayer):
	game_reset.emit(reset_type)

func emit_game_paused(paused: bool):
	game_paused.emit(paused)

func emit_save_request():
	save_request.emit()

func emit_save_completed():
	save_completed.emit()

func emit_card_drawn(card: Card, flipped: bool):
	card_drawn.emit(card, flipped)

func emit_card_calculated(card: Card, result: CardCalculationResult):
	card_calculated.emit(card, result)

func emit_request_shuffle(safely: bool):
	request_shuffle.emit(safely)

func emit_shuffle_completed(safely: bool):
	shuffle_completed.emit(safely)

func emit_deck_modified(operation: DataStructures.DeckOperation, card: Card = null):
	deck_modified.emit(operation, card)

func emit_shuffle_requested(safely: bool = false):
	request_shuffle.emit(safely)

func emit_clear_card():
	clear_card.emit()

func emit_pack_complete():
	pack_complete.emit()

func emit_show_revealed_cards(cards: Array):
	show_revealed_cards.emit(cards)

func emit_currency_updated(amount: int, currency_type: DataStructures.CurrencyType):
	currency_updated.emit(amount, currency_type)

func emit_request_buff_update(suit: DataStructures.SuitType, display_data: Dictionary):
	request_buff_update.emit(suit, display_data)

## Object for tooltip depends on prestige layer
func emit_tooltip_requested(object: Variant, layer: DataStructures.GameLayer, as_buff: bool = false):
	tooltip_requested.emit(object, layer, as_buff)

func emit_upgrade_purchased(upgrade: UpgradeData):
	upgrade_purchased.emit(upgrade)

func emit_floating_text_requested(num: float):
	floating_text_requested.emit(num)

func emit_sfx_requested(sfx_type: DataStructures.SFXType):
	sfx_requested.emit(sfx_type)

func emit_music_requested(music_type: DataStructures.MusicType):
	music_requested.emit(music_type)

func emit_suit_choice_requested(include_majors: bool):
	suit_choice_requested.emit(include_majors)
	player_input_requested.emit()

func emit_suit_chosen(suit: DataStructures.SuitType):
	suit_chosen.emit(suit)
	player_input_received.emit()

func emit_skip_choice_requested():
	skip_choice_requested.emit()
	player_input_requested.emit()

func emit_skip_chosen(skipped: bool):
	skip_chosen.emit(skipped)
	player_input_received.emit()

func emit_gamble_choice_requested():
	gamble_choice_requested.emit()
	player_input_requested.emit()

func emit_gamble_chosen(gamble: float):
	gamble_chosen.emit(gamble)
	player_input_received.emit()

func emit_card_choice_requested(choices: Array):
	card_choice_requested.emit(choices)
	player_input_requested.emit()

func emit_card_chosen(card: Card):
	card_chosen.emit(card)
	player_input_received.emit()

func emit_card_animation_finished():
	card_animation_finished.emit()

func emit_animation_requested(type: DataStructures.CardAnimationType, card: Card, flipped: bool):
	animation_requested.emit(type, card, flipped)

func emit_animation_step_completed(step: String):
	animation_step_completed.emit(step)

func emit_request_vfx(vfx_type: DataStructures.VFXType, animation_duration: float = -1):
	request_vfx.emit(vfx_type, animation_duration)

func emit_request_deck_change_animation(operation: DataStructures.DeckOperation, card: Card):
	request_deck_change_animation.emit(operation, card)

func emit_request_debug_menu():
	request_debug_menu.emit()
#endregion