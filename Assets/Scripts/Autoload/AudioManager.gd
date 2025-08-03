extends Node
class_name AudioManagerLegacy

enum SFX {
	CARD_FLIP,
	MENU_TAP,
	MENU_DING,
	PAGE_TURN
}
var _SFX_dict :Dictionary[int, String] = {
	SFX.CARD_FLIP: "_play_card_flip",
	SFX.MENU_TAP: "_play_menu_tap",
	SFX.MENU_DING: "_play_menu_ding",
	SFX.PAGE_TURN: "_play_page_turn"
}

@onready var card_flip: FmodEventEmitter2D = $CardFlip
@onready var menu_tap: FmodEventEmitter2D = $MenuTap
@onready var menu_ding: FmodEventEmitter2D = $MenuDing
@onready var page_turn: FmodEventEmitter2D = $PageTurn
@onready var music_track: FmodEventEmitter2D = $MusicManager/Music

func _ready() -> void:
	print("AudioManager ready")
	# EventBus.draw_card.connect(play_sfx.bind(DataStructures.SFXType.CARD_FLIP))
	# EventBus.sfx.connect(play_sfx)
	# _play_music()
	print("AudioManager initialized	")
	
func play_sfx(callable: SFX) -> void:
	if callable in SFX.values():
		call_deferred(_SFX_dict[callable])
	else:
		push_error("AudioManager: Invalid SFX callable: " + str(callable))

func _play_card_flip() -> void:
	card_flip.play_one_shot()

func _play_menu_tap() -> void:
	menu_tap.play_one_shot()

func _play_menu_ding() -> void:
	menu_ding.play_one_shot()

func _play_page_turn() -> void:
	page_turn.play_one_shot()

func _play_music() -> void:
	if music_track.paused == false:
		await _fade_out(music_track, 1.0)
	_fade_in(music_track, 1.0)

func _fade_in(emitter: FmodEventEmitter2D, speed: float) -> void:
	emitter.volume = 0.0  # Start muted
	emitter.play()
	await get_tree().create_timer(0.1).timeout  # Allow time for the track to start
	var tw: Tween = create_tween()
	tw.tween_property(emitter, "volume", 1.0, speed).set_trans(Tween.TRANS_SINE)
	await tw.finished

func _fade_out(emitter: FmodEventEmitter2D, speed: float) -> void:
	var tw: Tween = create_tween()
	tw.tween_property(emitter, "volume", 0.0, speed).set_trans(Tween.TRANS_SINE)
	await tw.finished
	emitter.stop()