extends RefCounted
class_name DataStructures

# enums
enum SuitType { CUPS, WANDS, PENTACLES, SWORDS, MAJOR, NONE }
enum CurrencyType { CLAIRVOYANCE, PACK }
enum GameLayer { DECK, PACK, BONES, POUCH, ALL }
enum CardState { INACTIVE, POSITIVE, NEGATIVE, UNKNOWN }
enum DeckOperation { ADD, REMOVE, SHUFFLE, CLEAR }
enum AnimationType { DRAW, FLIP, SHUFFLE, UPGRADE }
enum CardAnimationType { BASIC_CARD, MAJOR_CARD, GHOST_NEGATIVE, GHOST_POSITIVE }
enum SFXType { CARD_FLIP, MENU_TAP, MENU_DING, PAGE_TURN }
enum VFXType { CARD_SUCCESS, CARD_FAILURE }
enum MusicType { MAIN_THEME, VICTORY, DEFEAT }
enum GrowthType {LINEAR, SUPERLINEAR, SUBEXPONENTIAL, EXPONENTIAL, SLOW_EXPONENTIAL}
enum BuffType {BASIC, PAGE, KNIGHT, QUEEN, KING}
enum PanelColor {GOOD, BAD}

enum DeckType {DEFAULT, SELECTED, ACTIVE}

# Major Arcana IDs (Fool=0, Magician=1, ...)
enum MAJOR_ID {
	FOOL,
	MAGICIAN,
	HIGH_PRIESTESS,
	EMPRESS,
	EMPEROR,
	HIEROPHANT,
	LOVERS,
	CHARIOT,
	STRENGTH,
	HERMIT,
	WHEEL_OF_FORTUNE,
	JUSTICE,
	HANGED_MAN,
	DEATH,
	TEMPERANCE,
	DEVIL,
	TOWER,
	STAR,
	MOON,
	SUN,
	JUDGEMENT,
	WORLD
}


static var CUPS_COLOR: Color = Color.html("#1169be") #Color for cups suit
static var WANDS_COLOR: Color = Color.html("#509600") #Color for wands suit
static var PENTACLES_COLOR: Color = Color.html("#ce151e") #Color for pentacles suit
static var SWORDS_COLOR: Color = Color.html("#e2bc10") #Color for swords suit
static var MAJOR_COLOR: Color = Color.html("#a863da") #Color for major arcana
static var GOOD_COLOR: Color = Color.html("#007c1bff") #Color for good effects
static var BAD_COLOR: Color = Color.html("#b70003") #Color for bad effects
# Core colors for suits and effects
static var core_color: Dictionary = {
	CUPS = CUPS_COLOR,
	WANDS = WANDS_COLOR,
	PENTACLES = PENTACLES_COLOR,
	SWORDS = SWORDS_COLOR,
	MAJOR = MAJOR_COLOR,
	GOOD = GOOD_COLOR,
	BAD = BAD_COLOR
}