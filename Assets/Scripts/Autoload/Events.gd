extends Node

## @deprecated This Events autoload is deprecated. Use EventBus.gd instead.

signal draw_card
signal selected_card(card :DataStructures.Card, flipped: bool)
signal floating_text(value)
signal shuffle(safely: bool)
signal update_suit_displays
signal update_currency(value, type: DataStructures.CurrencyType)
signal card_value(value : float)
signal card_animation_major(flipped: bool)
signal card_draw_animation_finish
signal clear_card
signal add_card_to_deck(card: DataStructures.Card)
signal remove_card_from_deck(card: DataStructures.Card)
signal unlock_card(card: DataStructures.Card)
signal tooltip(base_tooltip: BaseTooltip)
signal card_tooltip(card: DataStructures.Card)
signal buff_tooltip(suit: DataStructures.SuitType, buff_type: ID.BuffType, card_number)
signal choose_suit(include_majors: bool)
signal chosen_suit(suit: DataStructures.SuitType)
signal choose_skip()
signal skip_choice(skipped: bool)
signal pause_drawing(pause:bool)
signal pack_complete
signal load_complete
signal save_request
signal reset(type: DataStructures.GameLayer)
signal hanged_man_choice
signal hanged_man_chosen(percent: float)
signal particle(particle_type: ID.ParticleType)
signal sfx(sfx_type: DataStructures.SFXType)

func emit_draw_card() -> void:
	draw_card.emit()

func emit_selected_card(card : DataStructures.Card, flipped : bool) -> void:
	selected_card.emit(card, flipped)

func emit_floating_text(value) -> void:
	floating_text.emit(value)

func emit_shuffle(safely : bool = false) -> void:
	shuffle.emit(safely)

func emit_update_suit_displays() -> void:
	update_suit_displays.emit()

func emit_update_currency(value, currency_type: DataStructures.CurrencyType = DataStructures.CurrencyType.CLAIRVOYANCE) -> void:
	update_currency.emit(value, currency_type)

func emit_card_value(value : float) -> void:
	card_value.emit(value)

func emit_card_draw_animation_finish() -> void:
	card_draw_animation_finish.emit()

func emit_clear_card() -> void:
	clear_card.emit()

func emit_add_card_to_deck(card: DataStructures.Card) -> void:
	add_card_to_deck.emit(card)

func emit_remove_card_from_deck(card: DataStructures.Card) -> void:
	remove_card_from_deck.emit(card)

func emit_unlock_card(card: DataStructures.Card) -> void:
	unlock_card.emit(card)

func emit_tooltip(base_tooltip: BaseTooltip) -> void:
	tooltip.emit(base_tooltip)
	
func emit_card_tooltip(card: DataStructures.Card) -> void:
	card_tooltip.emit(card)
	
func emit_buff_tooltip(suit: DataStructures.SuitType, buff_type: ID.BuffType, card_number: int = 0) -> void:
	buff_tooltip.emit(suit,buff_type, card_number)
	
func emit_choose_suit(include_majors: bool = false) -> void:
	choose_suit.emit(include_majors)
	
func emit_chosen_suit(suit: DataStructures.SuitType) -> void:
	chosen_suit.emit(suit)
	
func emit_pause_drawing(pause: bool) -> void:
	pause_drawing.emit(pause)
	
func emit_card_animation_major(flipped: bool) -> void:
	card_animation_major.emit(flipped)
	
func emit_load_complete() -> void:
	load_complete.emit()
	
func emit_save_request() -> void:
	save_request.emit()
	
func emit_reset(type: DataStructures.GameLayer) -> void:
	reset.emit(type)
	
func emit_choose_skip() -> void:
	choose_skip.emit()
	
func emit_skip_choice(skipping: bool) -> void:
	skip_choice.emit(skipping)

func emit_pack_complete() -> void:
	pack_complete.emit()

func emit_hanged_man_choice() -> void:
	hanged_man_choice.emit()

func emit_hanged_man_chosen(percent: float) -> void:
	hanged_man_chosen.emit(percent)

func emit_particle(type: ID.ParticleType) -> void:
	particle.emit(type)

func emit_sfx(sfx_type: DataStructures.SFXType) -> void:
	sfx.emit(sfx_type)