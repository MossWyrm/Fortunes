extends RefCounted
class_name GameState

# Core game systems
var deck_manager: DeckManager
var card_calculator: CardCalculator
var upgrade_manager: UpgradeManager
var audio_manager: AudioManager
var stats: GameStats

# Note: EventBus is now an autoload, no longer stored here

# Game state
var is_paused: bool = false

func _init() -> void:
	# Initialize systems in dependency order
	# Note: EventBus is now an autoload and available immediately
	stats = GameStats.new()
	
	deck_manager = DeckManager.new()
	card_calculator = CardCalculator.new()
	upgrade_manager = UpgradeManager.new()
	
	# AudioManager will be loaded and added to scene tree by GameManager
	# after GameState is created and scene tree is ready
	audio_manager = null  # Will be set by GameManager
	
	# Inject dependencies for RefCounted managers
	deck_manager.set_game_state(self)
	card_calculator.set_game_state(self)
	upgrade_manager.set_game_state(self)

	# Emit game_initialized AFTER managers have connected their signals
	EventBus.emit_game_initialized()
	print("Game State: Game Initialized")

# Initialize AudioManager when scene tree is available
func initialize_audio_manager(parent_node: Node) -> void:
	if audio_manager:
		return  # Already initialized
		
	var audio_scene = preload("res://Assets/Scenes/AudioManager.tscn")
	audio_manager = audio_scene.instantiate()
	parent_node.add_child(audio_manager)
	audio_manager.set_game_state(self)
	print("GameState: AudioManager initialized and added to scene tree")

func reset_game(reset_type: DataStructures.GameLayer):
	stats.reset(reset_type)
	deck_manager.reset(reset_type)
	upgrade_manager.reset(reset_type)
	EventBus.emit_game_reset(reset_type)

# Note: Save/Load functionality moved to AutoSaveNode
# GameState now focuses only on game logic and state management