extends RefCounted
class_name GameStats

# Core game stats
var clairvoyance: int = 0
var packs: int = 0
var tutorial_complete: bool = false

# General settings
var inversion_chance_modifier: float = 0.0
var max_deck_size: int = 56
var min_deck_size: int = 56

# Suit-specific stats
var cup_stats: CupStats
var wand_stats: WandStats
var pentacle_stats: PentacleStats
var sword_stats: SwordStats
var major_stats: MajorStats

# Pack settings
var pack_auto_draw: bool = false
var pack_auto_draw_speed: float = 5.0
var pack_card_value: int = 1

func _init():
	cup_stats = CupStats.new()
	wand_stats = WandStats.new()
	pentacle_stats = PentacleStats.new()
	sword_stats = SwordStats.new()
	major_stats = MajorStats.new()

func reset(reset_type: DataStructures.GameLayer):
	if reset_type >= DataStructures.GameLayer.DECK:
		reset_deck_stats()
	if reset_type >= DataStructures.GameLayer.PACK:
		reset_pack_stats()
	if reset_type >= DataStructures.GameLayer.ALL:
		reset_all_stats()

func reset_deck_stats():
	inversion_chance_modifier = 0.0
	max_deck_size = 56
	min_deck_size = 56
	cup_stats.reset()
	wand_stats.reset()
	pentacle_stats.reset()
	sword_stats.reset()
	major_stats.reset()

func reset_pack_stats():
	pack_auto_draw = false
	pack_auto_draw_speed = 5.0
	pack_card_value = 1

func reset_all_stats():
	clairvoyance = 0
	packs = 0
	tutorial_complete = false
	reset_deck_stats()
	reset_pack_stats()

func save() -> Dictionary:
	return {
		"clairvoyance": clairvoyance,
		"packs": packs,
		"tutorial_complete": tutorial_complete,
		"inversion_chance_modifier": inversion_chance_modifier,
		"max_deck_size": max_deck_size,
		"min_deck_size": min_deck_size,
		"cup_stats": cup_stats.save(),
		"wand_stats": wand_stats.save(),
		"pentacle_stats": pentacle_stats.save(),
		"sword_stats": sword_stats.save(),
		"major_stats": major_stats.save(),
		"pack_auto_draw": pack_auto_draw,
		"pack_auto_draw_speed": pack_auto_draw_speed,
		"pack_card_value": pack_card_value
	}

func load(data: Dictionary):
	if data.has("clairvoyance"):
		clairvoyance = data["clairvoyance"]
	if data.has("packs"):
		packs = data["packs"]
	if data.has("tutorial_complete"):
		tutorial_complete = data["tutorial_complete"]
	if data.has("inversion_chance_modifier"):
		inversion_chance_modifier = data["inversion_chance_modifier"]
	if data.has("max_deck_size"):
		max_deck_size = data["max_deck_size"]
	if data.has("min_deck_size"):
		min_deck_size = data["min_deck_size"]
	if data.has("cup_stats"):
		cup_stats.load(data["cup_stats"])
	if data.has("wand_stats"):
		wand_stats.load(data["wand_stats"])
	if data.has("pentacle_stats"):
		pentacle_stats.load(data["pentacle_stats"])
	if data.has("sword_stats"):
		sword_stats.load(data["sword_stats"])
	if data.has("major_stats"):
		major_stats.load(data["major_stats"])
	if data.has("pack_auto_draw"):
		pack_auto_draw = data["pack_auto_draw"]
	if data.has("pack_auto_draw_speed"):
		pack_auto_draw_speed = data["pack_auto_draw_speed"]
	if data.has("pack_card_value"):
		pack_card_value = data["pack_card_value"]