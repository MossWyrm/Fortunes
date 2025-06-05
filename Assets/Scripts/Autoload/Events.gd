extends Node

signal draw_card
signal selected_card(card : Card, flipped: bool)
signal floating_text(value)
signal shuffle(safely: bool)
signal update_suit_displays
signal update_currency_display(value)
signal card_value(value : float)
signal card_draw_animation_finish
signal clear_card
signal add_card_to_deck(card: Card)
signal remove_card_from_deck(card: Card)
signal unlock_card(card: Card)
signal tooltip(base_tooltip: BaseTooltip)
signal card_tooltip(card: Card)


func emit_draw_card() -> void:
	draw_card.emit()

func emit_selected_card(card : Card, flipped : bool) -> void:
	selected_card.emit(card, flipped)

func emit_floating_text(value) -> void:
	floating_text.emit(value)

func emit_shuffle(safely : bool = false) -> void:
	shuffle.emit(safely)

func emit_update_suit_displays() -> void:
	update_suit_displays.emit()

func emit_update_currency_display(value) -> void:
	update_currency_display.emit(value)

func emit_card_value(value : float) -> void:
	card_value.emit(value)

func emit_card_draw_animation_finish() -> void:
	card_draw_animation_finish.emit()

func emit_clear_card() -> void:
	clear_card.emit()

func emit_add_card_to_deck(card: Card) -> void:
	add_card_to_deck.emit(card)

func emit_remove_card_from_deck(card: Card) -> void:
	remove_card_from_deck.emit(card)

func emit_unlock_card(card: Card) -> void:
	unlock_card.emit(card)

func emit_tooltip(base_tooltip: BaseTooltip) -> void:
	tooltip.emit(base_tooltip)
	
func emit_card_tooltip(card: Card) -> void:
	card_tooltip.emit(card)