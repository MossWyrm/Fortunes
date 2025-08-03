extends RefCounted
class_name GameConfig

# Game configuration singleton
static var instance: GameConfig

# Default values
const DEFAULT_CLAIRVOYANCE = 0
const DEFAULT_PACKS = 0
const DEFAULT_MAX_DECK_SIZE = 56
const DEFAULT_MIN_DECK_SIZE = 56
const DEFAULT_INVERSION_CHANCE = 0.0

# Suit-specific defaults
const DEFAULT_CUP_BASIC_VALUE = 0
const DEFAULT_CUP_basic_max_quantity = 1
const DEFAULT_CUP_face_max_quantity = 1
const DEFAULT_CUP_VESSEL_QUANTITY = 1
const DEFAULT_CUP_VESSEL_SIZE = 100
const DEFAULT_CUP_PAGE_MODIFIER = 0.2
const DEFAULT_CUP_KNIGHT_MODIFIER = 1
const DEFAULT_CUP_QUEEN_MODIFIER = 1

const DEFAULT_WAND_BASIC_VALUE = 0
const DEFAULT_WAND_basic_max_quantity = 1
const DEFAULT_WAND_face_max_quantity = 1
const DEFAULT_WAND_PAGE_MODIFIER = 1
const DEFAULT_WAND_KNIGHT_MODIFIER = 1
const DEFAULT_WAND_QUEEN_MODIFIER = 1
const DEFAULT_WAND_KING_MODIFIER = 2

const DEFAULT_PENTACLE_BASIC_VALUE = 0
const DEFAULT_PENTACLE_basic_max_quantity = 1
const DEFAULT_PENTACLE_face_max_quantity = 1
const DEFAULT_PENTACLE_PAGE_MODIFIER = 0.1
const DEFAULT_PENTACLE_KNIGHT_USES = 1
const DEFAULT_PENTACLE_QUEEN_USES = 1
const DEFAULT_PENTACLE_KING_USES = 3
const DEFAULT_PENTACLE_KING_VALUE = 100

const DEFAULT_SWORD_BASIC_VALUE = 0
const DEFAULT_SWORD_basic_max_quantity = 1
const DEFAULT_SWORD_face_max_quantity = 1
const DEFAULT_SWORD_KNIGHT_MODIFIER = 5
const DEFAULT_SWORD_KNIGHT_SUPER = false
const DEFAULT_SWORD_QUEEN_MODIFIER = 1
const DEFAULT_SWORD_KING_MODIFIER = 3

const DEFAULT_MAJOR_QUANTITY = 1
const DEFAULT_MAJOR_MAGICIAN = 5
const DEFAULT_MAJOR_EMPRESS = 1
const DEFAULT_MAJOR_EMPEROR = 1
const DEFAULT_MAJOR_LOVERS = 4
const DEFAULT_MAJOR_WHEEL_MULTIPLIER = 2
const DEFAULT_MAJOR_WHEEL_CHARGES = 5
const DEFAULT_MAJOR_HANGED_MAN = 2
const DEFAULT_MAJOR_TEMPERANCE = 100
const DEFAULT_MAJOR_DEVIL = 3
const DEFAULT_MAJOR_STAR = 5
const DEFAULT_MAJOR_MOON = 2
const DEFAULT_MAJOR_SUN_STAR = 10
const DEFAULT_MAJOR_SUN_MOON = 3
const DEFAULT_MAJOR_JUDGEMENT = 10
const DEFAULT_MAJOR_HIGH_PRIESTESS = 3
const DEFAULT_MAJOR_HIEROPHANT = 2
const DEFAULT_MAJOR_STRENGTH = 5
const DEFAULT_MAJOR_JUSTICE = 1
const DEFAULT_MAJOR_DEATH = 1

# Pack defaults
const DEFAULT_PACK_AUTO_DRAW = false
const DEFAULT_PACK_AUTO_DRAW_SPEED = 5.0
const DEFAULT_PACK_CARD_VALUE = 1

# Save system defaults
const DEFAULT_AUTOSAVE_FREQUENCY = 10.0
const SAVE_FILE_PATH = "user://save.json"

# Audio defaults
const DEFAULT_SFX_VOLUME = 1.0
const DEFAULT_MUSIC_VOLUME = 0.8

# UI defaults
const DEFAULT_TOOLTIP_DELAY = 0.5
const DEFAULT_ANIMATION_SPEED = 1.0

# Card defaults
const DEFAULT_CARD_FLIP_CHANCE = 0.5
const MAX_CARD_VALUE = 10000
const MIN_CARD_VALUE = -10000

# Upgrade defaults
const DEFAULT_UPGRADE_GROWTH_MODIFIER = 1.0
const DEFAULT_UPGRADE_MAX_PURCHASES = -1

# Validation ranges
const VALID_DECK_SIZE_RANGE = Vector2(1, 1000)
const VALID_CURRENCY_RANGE = Vector2(0, 9999999999)
const VALID_MODIFIER_RANGE = Vector2(-100, 100)
const VALID_CHANCE_RANGE = Vector2(0.0, 1.0)

static func get_instance() -> GameConfig:
	if instance == null:
		instance = GameConfig.new()
	return instance

func validate_stat(stat_name: String, value: Variant) -> bool:
	match stat_name:
		"clairvoyance", "packs":
			return value >= VALID_CURRENCY_RANGE.x and value <= VALID_CURRENCY_RANGE.y
		"max_deck_size", "min_deck_size":
			return value >= VALID_DECK_SIZE_RANGE.x and value <= VALID_DECK_SIZE_RANGE.y
		"inversion_chance_modifier":
			return value >= VALID_CHANCE_RANGE.x and value <= VALID_CHANCE_RANGE.y
		_:
			return true

func get_default_value(stat_name: String) -> Variant:
	match stat_name:
		"clairvoyance":
			return DEFAULT_CLAIRVOYANCE
		"packs":
			return DEFAULT_PACKS
		"max_deck_size":
			return DEFAULT_MAX_DECK_SIZE
		"min_deck_size":
			return DEFAULT_MIN_DECK_SIZE
		"inversion_chance_modifier":
			return DEFAULT_INVERSION_CHANCE
		"cup_basic_value":
			return DEFAULT_CUP_BASIC_VALUE
		"cup_basic_max_quantity":
			return DEFAULT_CUP_basic_max_quantity
		"cup_face_max_quantity":
			return DEFAULT_CUP_face_max_quantity
		"cup_vessel_quantity":
			return DEFAULT_CUP_VESSEL_QUANTITY
		"cup_vessel_size":
			return DEFAULT_CUP_VESSEL_SIZE
		"cup_page_modifier":
			return DEFAULT_CUP_PAGE_MODIFIER
		"cup_knight_modifier":
			return DEFAULT_CUP_KNIGHT_MODIFIER
		"cup_queen_modifier":
			return DEFAULT_CUP_QUEEN_MODIFIER
		"wand_basic_value":
			return DEFAULT_WAND_BASIC_VALUE
		"wand_basic_max_quantity":
			return DEFAULT_WAND_basic_max_quantity
		"wand_face_max_quantity":
			return DEFAULT_WAND_face_max_quantity
		"wand_page_modifier":
			return DEFAULT_WAND_PAGE_MODIFIER
		"wand_knight_modifier":
			return DEFAULT_WAND_KNIGHT_MODIFIER
		"wand_queen_modifier":
			return DEFAULT_WAND_QUEEN_MODIFIER
		"wand_king_modifier":
			return DEFAULT_WAND_KING_MODIFIER
		"pentacle_basic_value":
			return DEFAULT_PENTACLE_BASIC_VALUE
		"pentacle_basic_max_quantity":
			return DEFAULT_PENTACLE_basic_max_quantity
		"pentacle_face_max_quantity":
			return DEFAULT_PENTACLE_face_max_quantity
		"pentacle_page_modifier":
			return DEFAULT_PENTACLE_PAGE_MODIFIER
		"pentacle_knight_uses":
			return DEFAULT_PENTACLE_KNIGHT_USES
		"pentacle_queen_uses":
			return DEFAULT_PENTACLE_QUEEN_USES
		"pentacle_king_uses":
			return DEFAULT_PENTACLE_KING_USES
		"pentacle_king_value":
			return DEFAULT_PENTACLE_KING_VALUE
		"sword_basic_value":
			return DEFAULT_SWORD_BASIC_VALUE
		"sword_basic_max_quantity":
			return DEFAULT_SWORD_basic_max_quantity
		"sword_face_max_quantity":
			return DEFAULT_SWORD_face_max_quantity
		"sword_knight_modifier":
			return DEFAULT_SWORD_KNIGHT_MODIFIER
		"sword_knight_super":
			return DEFAULT_SWORD_KNIGHT_SUPER
		"sword_queen_modifier":
			return DEFAULT_SWORD_QUEEN_MODIFIER
		"sword_king_modifier":
			return DEFAULT_SWORD_KING_MODIFIER
		"major_quantity":
			return DEFAULT_MAJOR_QUANTITY
		"major_magician":
			return DEFAULT_MAJOR_MAGICIAN
		"major_empress":
			return DEFAULT_MAJOR_EMPRESS
		"major_emperor":
			return DEFAULT_MAJOR_EMPEROR
		"major_lovers":
			return DEFAULT_MAJOR_LOVERS
		"major_wheel_multiplier":
			return DEFAULT_MAJOR_WHEEL_MULTIPLIER
		"major_wheel_charges":
			return DEFAULT_MAJOR_WHEEL_CHARGES
		"major_hanged_man":
			return DEFAULT_MAJOR_HANGED_MAN
		"major_temperance":
			return DEFAULT_MAJOR_TEMPERANCE
		"major_devil":
			return DEFAULT_MAJOR_DEVIL
		"major_star":
			return DEFAULT_MAJOR_STAR
		"major_moon":
			return DEFAULT_MAJOR_MOON
		"major_sun_star":
			return DEFAULT_MAJOR_SUN_STAR
		"major_sun_moon":
			return DEFAULT_MAJOR_SUN_MOON
		"major_judgement":
			return DEFAULT_MAJOR_JUDGEMENT
		"major_high_priestess":
			return DEFAULT_MAJOR_HIGH_PRIESTESS
		"major_hierophant":
			return DEFAULT_MAJOR_HIEROPHANT
		"major_strength":
			return DEFAULT_MAJOR_STRENGTH
		"major_justice":
			return DEFAULT_MAJOR_JUSTICE
		"major_death":
			return DEFAULT_MAJOR_DEATH
		"pack_auto_draw":
			return DEFAULT_PACK_AUTO_DRAW
		"pack_auto_draw_speed":
			return DEFAULT_PACK_AUTO_DRAW_SPEED
		"pack_card_value":
			return DEFAULT_PACK_CARD_VALUE
		_:
			return null 