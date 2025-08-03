extends RefCounted
class_name AudioManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Audio settings
var sfx_volume: float = 1.0
var music_volume: float = 0.8
var master_volume: float = 1.0

func set_game_state(state: GameState):
	game_state = state
	event_bus = state.event_bus
	_connect_events()

func _connect_events():
	event_bus.sfx_requested.connect(_on_sfx_requested)
	event_bus.music_requested.connect(_on_music_requested)
	event_bus.card_drawn.connect(_on_card_drawn)

func _on_sfx_requested(sfx_type: DataStructures.SFXType):
	play_sfx(sfx_type)

func _on_music_requested(music_type: DataStructures.MusicType):
	play_music(music_type)

func _on_card_drawn(_card: DataStructures.Card, _flipped: bool):
	# Play card flip sound
	play_sfx(DataStructures.SFXType.CARD_FLIP)

func play_sfx(sfx_type: DataStructures.SFXType):
	# This would integrate with your FMOD system
	match sfx_type:
		DataStructures.SFXType.CARD_FLIP:
			print("Playing card flip sound")
		DataStructures.SFXType.MENU_TAP:
			print("Playing menu tap sound")
		DataStructures.SFXType.MENU_DING:
			print("Playing menu ding sound")
		DataStructures.SFXType.PAGE_TURN:
			print("Playing page turn sound")

func play_music(music_type: DataStructures.MusicType):
	# This would integrate with your FMOD system
	match music_type:
		DataStructures.MusicType.MAIN_THEME:
			print("Playing main theme")
		DataStructures.MusicType.VICTORY:
			print("Playing victory music")
		DataStructures.MusicType.DEFEAT:
			print("Playing defeat music")

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)

func get_sfx_volume() -> float:
	return sfx_volume * master_volume

func get_music_volume() -> float:
	return music_volume * master_volume

func reset(_reset_type: DataStructures.GameLayer):
	# Audio settings typically don't reset with game resets
	pass 