extends Node
class_name CurrencyManager

# === Exported Currency Displays ===
@export var clairvoyance_display: CurrencyDisplay
@export var packs_display: CurrencyDisplay

# === Internal State ===
var _clairvoyance: int:
	get: 
		if ValidationUtils.has_game_state():
			return GameManager.game_state.stats.clairvoyance
		return 0
	set(value): 
		if ValidationUtils.has_game_state():
			GameManager.game_state.stats.clairvoyance = value

var _packs: int:
	get: 
		if ValidationUtils.has_game_state():
			return GameManager.game_state.stats.packs
		return 0
	set(value): 
		if ValidationUtils.has_game_state():
			GameManager.game_state.stats.packs = value

var _tweens := {}

# === Godot Lifecycle ===
func _ready() -> void:
	SignalManager.safe_connect(GameManager.event_bus.currency_updated, update_currency, "CurrencyManager currency_updated")
	SignalManager.safe_connect(GameManager.event_bus.game_reset, reset, "CurrencyManager game_reset")
	clairvoyance_display.update_text(_clairvoyance)
	if !packs_display.is_visible() and _packs >= 1:
		packs_display.show()
		packs_display.update_text(_packs)

# === Currency Update Routing ===
func update_currency(card_value, currency_type: DataStructures.CurrencyType) -> void:
	match currency_type:
		DataStructures.CurrencyType.CLAIRVOYANCE:
			_update_currency_animated(
				clairvoyance_display,
				_clairvoyance,
				_clairvoyance + card_value,
				func(val): _clairvoyance = val
			)
			_emit_floating_text(card_value, _clairvoyance)
		DataStructures.CurrencyType.PACK:
			if !packs_display.is_visible() and _packs + card_value >= 1:
				packs_display.show()
			_update_currency_animated(
				packs_display,
				_packs,
				_packs + card_value,
				func(val): _packs = val
			)
			_emit_floating_text(card_value, _packs)

# === Animated Currency Update ===
func _update_currency_animated(display, old_value, new_value, set_stat_func):
	if _tweens.has(display):
		_tweens[display].kill()
	var tween = create_tween()
	_tweens[display] = tween

	tween.tween_property(self, "_dummy", 1.0, 0.5).from(0.0) # Dummy property to drive the step
	tween.connect("tween_step", func():
		var t = tween.get_total_elapsed_time() / tween.get_total_duration()
		var lerped = lerp(old_value, new_value, t)
		display.update_text(round(lerped))
	)
	tween.connect("finished", func():
		set_stat_func.call(new_value)
		display.update_text(new_value)
		_tweens.erase(display)
	)

# === Floating Text Logic ===
func _emit_floating_text(card_value, stat_value):
	if stat_value + card_value <= 0:
		GameManager.event_bus.emit_floating_text_requested(-stat_value)
	else:
		GameManager.event_bus.emit_floating_text_requested(card_value)

# === Reset Logic ===
func reset(type: DataStructures.GameLayer) -> void:
	if type >= DataStructures.GameLayer.DECK:
		_clairvoyance = 0
		clairvoyance_display.update_text(_clairvoyance)
	if type >= DataStructures.GameLayer.PACK:
		packs_display.hide()
		_packs = 0
		packs_display.update_text(_packs)
