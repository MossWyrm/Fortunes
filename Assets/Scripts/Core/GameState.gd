extends RefCounted
class_name GameState

# Core game systems
var deck_manager: DeckManager
var card_calculator: CardCalculator
var upgrade_manager: UpgradeManager
var save_manager: SaveManager
var audio_manager: AudioManager
var stats: GameStats

# Event system
var event_bus: EventBus

# Game state
var is_initialized: bool = false
var is_paused: bool = false

func _init():
	event_bus = EventBus.new()
	stats = GameStats.new()
	
func initialize():
	if is_initialized:
		return
		
	# Initialize systems in dependency order
	deck_manager = DeckManager.new()
	card_calculator = CardCalculator.new()
	upgrade_manager = UpgradeManager.new()
	save_manager = SaveManager.new()
	audio_manager = AudioManager.new()
	
	# Inject dependencies
	deck_manager.set_game_state(self)
	card_calculator.set_game_state(self)
	upgrade_manager.set_game_state(self)
	save_manager.set_game_state(self)
	audio_manager.set_game_state(self)

	is_initialized = true
	event_bus.emit_game_initialized()

func reset_game(reset_type: DataStructures.GameLayer):
	stats.reset(reset_type)
	deck_manager.reset(reset_type)
	upgrade_manager.reset(reset_type)
	event_bus.emit_game_reset(reset_type)

func save_game():
	var save_data = {
		"stats": stats.save(),
		"deck": deck_manager.save(),
		"upgrades": upgrade_manager.save()
	}
	save_manager.save(save_data)

func load_game():
	var save_data = save_manager.load()
	if save_data:
		stats.load(save_data.get("stats", {}))
		deck_manager.load(save_data.get("deck", {}))
		upgrade_manager.load(save_data.get("upgrades", {}))
		event_bus.emit_game_loaded() 