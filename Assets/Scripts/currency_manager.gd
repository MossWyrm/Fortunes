extends Node
class_name CurrencyManager

@export var clairvoyance_display: CurrencyDisplay
@export var packs_display: CurrencyDisplay

var _clairvoyance: int:
	get:
		return Stats.clairvoyance
	set(value):
		Stats.clairvoyance = value

var _packs: int:
	get:
		return Stats.packs
	set(value):
		Stats.packs = value

func _ready() -> void:
	Events.update_currency.connect(update_currency)
	Events.reset.connect(reset)
	clairvoyance_display.update_text(_clairvoyance)
	if !packs_display.is_visible() && _packs >= 1:
		packs_display.show()


func update_currency(card_value, currency_type: ID.CurrencyType) -> void:
	match currency_type:
		ID.CurrencyType.CLAIRVOYANCE: update_clairvoyance(card_value)
		ID.CurrencyType.PACK: update_pack(card_value)

	
func update_clairvoyance(card_value) -> void:
	if _clairvoyance + card_value <= 0:
		Events.emit_floating_text(-_clairvoyance)
	else:
		Events.emit_floating_text(card_value)
	_clairvoyance += card_value
	if _clairvoyance < 0:
		_clairvoyance = 0
	clairvoyance_display.update_text(_clairvoyance)
	
func update_pack(value) -> void:
	if !packs_display.is_visible() && _packs+value >= 1:
		packs_display.show()
	if _packs + value <= 0:
		Events.emit_floating_text(-_packs)
	else:
		Events.emit_floating_text(value)
	_packs += value
	if _packs < 0:
		_packs = 0
	packs_display.update_text(_packs)
	
func reset(type: ID.PrestigeLayer) -> void:
	if type >= ID.PrestigeLayer.DECK:
		_clairvoyance = 0
		clairvoyance_display.update_text(_clairvoyance)
	if type >= ID.PrestigeLayer.PACK:
		packs_display.hide()
		_packs = 0
		packs_display.update_text(_packs)
