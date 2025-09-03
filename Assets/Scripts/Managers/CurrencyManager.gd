extends Node
class_name CurrencyManager

@export var clairvoyance_display: CurrencyDisplay
@export var packs_display: CurrencyDisplay

var currency_animation: float = 0.0

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

func _ready() -> void:
	# Direct EventBus connections - always available as autoload
	EventBus.currency_updated.connect(update_currency)
	EventBus.game_reset.connect(reset)
	EventBus.game_loaded.connect(_on_game_loaded)
	clairvoyance_display.update_text(_clairvoyance)
	if !packs_display.is_visible() and _packs >= 1:
		packs_display.show()
		packs_display.update_text(_packs)

# === Event Handlers ===
func _on_game_loaded() -> void:
	# Refresh currency displays after loading
	clairvoyance_display.update_text(_clairvoyance)
	if _packs >= 1:
		packs_display.show()
		packs_display.update_text(_packs)
	else:
		packs_display.hide()

# === Currency Update Routing ===
func update_currency(card_value, currency_type: DataStructures.CurrencyType) -> void:
	match currency_type:
		DataStructures.CurrencyType.CLAIRVOYANCE:
			var target_value = 0 if _clairvoyance + card_value < 0 else _clairvoyance + card_value
			_update_currency_animated(
				clairvoyance_display,
				_clairvoyance,
				target_value,
				func(val): _clairvoyance = val
			)
			_emit_floating_text(card_value, _clairvoyance)
		DataStructures.CurrencyType.PACK:
			if !packs_display.is_visible() and _packs + card_value >= 1:
				packs_display.show()
			var target_value = 0 if _packs + card_value < 0 else _packs + card_value
			_update_currency_animated(
				packs_display,
				_packs,
				target_value,
				func(val): _packs = val
			)
			_emit_floating_text(card_value, _packs)

# === Animated Currency Update ===
func _update_currency_animated(display, old_value, new_value, set_stat_func):
	if _tweens.has(display):
		_tweens[display].kill()
	var tween = create_tween()
	_tweens[display] = tween
	var tween_speed = GameManager.game_state.stats.pack_auto_draw_speed if GameManager.game_state.stats.pack_auto_draw_speed < 1.5 else 1.5
	tween.tween_method(func(x): display.update_text(round(x)), old_value, new_value, tween_speed).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		set_stat_func.call(new_value)
		display.update_text(new_value)
		_tweens.erase(display)
	)

# === Floating Text Logic ===
func _emit_floating_text(card_value, stat_value):
	var value = -stat_value if stat_value + card_value <= 0 else card_value
	EventBus.emit_floating_text_requested(value)

# === Reset Logic ===
func reset(type: DataStructures.GameLayer) -> void:
	if type >= DataStructures.GameLayer.DECK:
		_clairvoyance = 0
		clairvoyance_display.update_text(_clairvoyance)
	if type >= DataStructures.GameLayer.PACK:
		packs_display.hide()
		_packs = 0
		packs_display.update_text(_packs)
