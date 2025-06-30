extends Node
class_name SaveManager

@onready var timer: Timer = $Timer
@export var autosave_frequency: float = 10.0
@onready var writer: SaveWriter = SaveWriter.new()

func _ready() -> void:
	GM.save_manager = self
	initialize()
	timer.start(autosave_frequency)
	timer.timeout.connect(auto_save)

func auto_save() -> void:
	print("Autosaving")
	Events.emit_save_request()

func initialize():
	if writer.save_exists():
		await GM.references_ready
		load_save()
	Events.save_request.connect(write_save)
	Events.reset.connect(reset)
	
func write_save() -> void:
	var data := {
		"deck" = GM.deck_manager.save_deck(),
		"stats" = Stats.save(),
		"upgrades" = GM.upgrade_manager.save()
	}	
	writer.write_savegame(data)
	
func load_save() -> void:
	var data: Dictionary = writer.load_savegame()
	if !data.is_empty():
		GM.deck_manager.load_deck(data["deck"])
		Stats.load_stats(data["stats"])
		GM.upgrade_manager.load_upgrades(data["upgrades"])
	Events.emit_load_complete()
	print("Load completed")
	
func clear_save() -> void:
	writer.clear_save()
	
func reset(type: ID.PrestigeLayer) -> void:
	if type == ID.PrestigeLayer.ALL:
		clear_save()