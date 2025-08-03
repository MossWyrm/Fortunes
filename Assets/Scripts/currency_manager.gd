extends Node
class_name CurrencyManager

@export var clairvoyance_display: CurrencyDisplay
@export var packs_display: CurrencyDisplay

var _clairvoyance: int:
	get:
		return GameManager.game_state.stats.clairvoyance
	set(value):
		GameManager.game_state.stats.clairvoyance = value

var _packs: int:
	get:
		return GameManager.game_state.stats.packs
	set(value):
		GameManager.game_state.stats.packs = value

func _ready() -> void:
	GameManager.event_bus.currency_updated.connect(update_currency)
	GameManager.event_bus.game_reset.connect(reset)
	clairvoyance_display.update_text(_clairvoyance)
	if !packs_display.is_visible() && _packs >= 1:
		packs_display.show()


func update_currency(card_value, currency_type: DataStructures.CurrencyType) -> void:
	match currency_type:
		DataStructures.CurrencyType.CLAIRVOYANCE: update_clairvoyance(card_value)
		DataStructures.CurrencyType.PACK: update_pack(card_value)

	
func update_clairvoyance(card_value) -> void:
	if _clairvoyance + card_value <= 0:
		GameManager.event_bus.emit_floating_text_requested(-_clairvoyance)
	else:
		GameManager.event_bus.emit_floating_text_requested(card_value)
	_clairvoyance += card_value
	if _clairvoyance < 0:
		_clairvoyance = 0
	clairvoyance_display.update_text(_clairvoyance)
	
func update_pack(value) -> void:
	if !packs_display.is_visible() && _packs+value >= 1:
		packs_display.show()
	if _packs + value <= 0:
		GameManager.event_bus.emit_floating_text_requested(-_packs)
	else:
		GameManager.event_bus.emit_floating_text_requested(value)
	_packs += value
	if _packs < 0:
		_packs = 0
	packs_display.update_text(_packs)
	
func reset(type: DataStructures.GameLayer) -> void:
	if type >= DataStructures.GameLayer.DECK:
		_clairvoyance = 0
		clairvoyance_display.update_text(_clairvoyance)
	if type >= DataStructures.GameLayer.PACK:
		packs_display.hide()
		_packs = 0
		packs_display.update_text(_packs)
