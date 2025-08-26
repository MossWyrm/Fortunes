extends RefCounted
class_name GameConstants

## Game Constants
## Centralized location for all magic numbers and configuration values

#region UI Constants
const DEFAULT_ANIMATION_SPEED: float = 1.0
const PROGRESS_CLAMP_MIN: float = 0.0
const PROGRESS_CLAMP_MAX: float = 1.0
const CARD_SCALE_SMALL: Vector2 = Vector2(0.5, 0.5)
const HOLD_DELAY_DEFAULT: float = 1.0
const HOLD_TO_PURCHASE_DELAY: float = 1.0
#endregion

#region Card System Constants
const CARD_ID_SUIT_MULTIPLIER: int = 100
const CARD_ID_FACE_OFFSET: int = 10
const MAJOR_CARD_THRESHOLD: int = 500
const CARD_VALUE_MOD: int = 100
const SUIT_CARD_COUNT: int = 100
const MAJOR_CARD_COUNT: int = 22
const FACE_CARD_THRESHOLD: int = 10

# Card ranks
const CARD_RANK_PAGE: int = 11
const CARD_RANK_KNIGHT: int = 12
const CARD_RANK_QUEEN: int = 13
const CARD_RANK_KING: int = 14

# Card art dimensions
const CARD_ART_WIDTH: int = 400
const CARD_ART_HEIGHT: int = 699

# Suit ID offsets for deck generation
const SUIT_OFFSET_CUPS: int = 100
const SUIT_OFFSET_WANDS: int = 200
const SUIT_OFFSET_PENTACLES: int = 300
const SUIT_OFFSET_SWORDS: int = 400
#endregion

#region Currency Constants
const DEBUG_MONEY_AMOUNT: int = 1000
const NUMBER_FORMAT_THRESHOLD: int = 1000
const NUMBER_FORMAT_DIVISOR: float = 1000.0
const LARGE_NUMBER_THRESHOLD: int = 100
const MEDIUM_NUMBER_THRESHOLD: int = 10
#endregion

#region Animation Constants
const SPAWN_POSITION_VARIANCE: int = 100
const BURN_FADE_START: float = 1.0
const BURN_FADE_END: float = 0.0
const ANIMATION_SCALE_FULL: Vector2 = Vector2(1.0, 1.0)
#endregion

#region Gamble Constants
const GAMBLE_TEN_PERCENT: float = 0.1
const GAMBLE_QUARTER_PERCENT: float = 0.25
const GAMBLE_HALF_PERCENT: float = 0.5
const GAMBLE_FULL_PERCENT: float = 1.0
#endregion

#region File System Constants
const JSON_PREVIEW_LENGTH: int = 100
#endregion

#region Debug Constants
const DEBUG_ENABLED: bool = false
#endregion

#region UI Layout Constants
const TOOLTIP_MAX_WIDTH: int = 300
const UPGRADE_BUTTON_MIN_SIZE: Vector2 = Vector2(80, 150)
const THEME_MARGIN_STANDARD: float = 5.0
const LOADING_SCENE_MARGIN: int = 30
#endregion

#region Shader Constants
const SHADER_BURN_TRANSITION_POWER: float = 20.0
const SHADER_WARP_POWER: float = 2.0
#endregion

#region Debug Constants
const DEBUG_CARD_FLIP_CHANCE: float = 0.5
#endregion

## Helper functions for common calculations
static func calculate_card_id(suit: int, buff_type: int) -> int:
	return ((suit + 1) * CARD_ID_SUIT_MULTIPLIER) + CARD_ID_FACE_OFFSET + buff_type

static func get_card_value_from_id(card_id: int) -> int:
	return card_id % CARD_VALUE_MOD

static func is_major_card(card_id: int) -> bool:
	return card_id >= MAJOR_CARD_THRESHOLD

static func get_random_spawn_variance() -> int:
	return randi_range(-SPAWN_POSITION_VARIANCE, SPAWN_POSITION_VARIANCE)
