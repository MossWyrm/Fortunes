extends Node
class_name AudioManager

# Dependencies
var game_state: GameState
var event_bus: EventBus

# Audio settings
var sfx_volume: float = 1.0
var music_volume: float = 0.8
var master_volume: float = 1.0

# FMOD Event Emitters (will be assigned from scene)
@onready var card_flip_emitter: FmodEventEmitter2D = $CardFlip
@onready var menu_tap_emitter: FmodEventEmitter2D = $MenuTap
@onready var menu_ding_emitter: FmodEventEmitter2D = $MenuDing
@onready var page_turn_emitter: FmodEventEmitter2D = $PageTurn
@onready var music_emitter: FmodEventEmitter2D = $MusicManager/Music

func _ready():
	# AudioManager will be initialized by GameState when it's created
	pass

func set_game_state(state: GameState):
	game_state = state
	_connect_events()

func _connect_events():
	EventBus.sfx_requested.connect(_on_sfx_requested)
	EventBus.music_requested.connect(_on_music_requested)
	EventBus.card_drawn.connect(_on_card_drawn)

func _on_sfx_requested(sfx_type: DataStructures.SFXType):
	play_sfx(sfx_type)

func _on_music_requested(music_type: DataStructures.MusicType):
	play_music(music_type)

func _on_card_drawn(_card: Card, _flipped: bool):
	# Play card flip sound
	play_sfx(DataStructures.SFXType.CARD_FLIP)

func play_sfx(sfx_type: DataStructures.SFXType):
	# Play FMOD events using the scene emitters
	match sfx_type:
		DataStructures.SFXType.CARD_FLIP:
			if card_flip_emitter:
				card_flip_emitter.play()
		DataStructures.SFXType.MENU_TAP:
			if menu_tap_emitter:
				menu_tap_emitter.play()
		DataStructures.SFXType.MENU_DING:
			if menu_ding_emitter:
				menu_ding_emitter.play()
		DataStructures.SFXType.PAGE_TURN:
			if page_turn_emitter:
				page_turn_emitter.play()

func play_music(music_type: DataStructures.MusicType):
	# Handle music with the FMOD music emitter
	if not music_emitter:
		return
		
	match music_type:
		DataStructures.MusicType.MAIN_THEME:
			# Set music intensity parameter for main theme
			music_emitter.set_parameter("Music Intensity", 0.5)
			music_emitter.play()
		DataStructures.MusicType.VICTORY:
			# Set game end parameter for victory
			music_emitter.set_parameter("Game End", 1.0)
			music_emitter.play()
		DataStructures.MusicType.DEFEAT:
			# Set game end parameter for defeat  
			music_emitter.set_parameter("Game End", 0.0)
			music_emitter.play()

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