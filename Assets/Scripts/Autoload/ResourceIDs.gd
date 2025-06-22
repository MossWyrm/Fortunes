extends Node
class_name ResourceIDs

enum Suits {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, NONE = 5}
enum UpgradeType {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, GENERAL = 5}
enum BuffType {GENERAL = 0, PAGE = 1, KNIGHT = 2, QUEEN = 3, KING = 4}
enum CurrencyType {CLAIRVOYANCE = 0, PACK = 1}
enum CardState {INACTIVE = 0, POSITIVE = 1, NEGATIVE = 2, UNKNOWN = 3}
enum BasicID{
	ONE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	PAGE = 11,
	KNIGHT = 12,
	QUEEN = 13,
	KING = 14
}
enum MajorID {
	FOOL 				= 1,
	MAGICIAN 			= 2, 
	HIGH_PRIESTESS		= 3, 
	EMPRESS				= 4,
	EMPEROR				= 5,
	HEIROPHANT			= 6, 
	LOVERS				= 7,
	CHARIOT				= 8, 
	STRENGTH			= 9, 
	HERMIT				= 10,
	WHEEL_OF_FORTUNE	= 11,
	JUSTICE				= 12,
	HANGED_MAN			= 13, 
	DEATH				= 14,
	TEMPERANCE			= 15, 
	DEVIL				= 16,
	TOWER				= 17,
	STAR				= 18,
	MOON				= 19,
	SUN					= 20,
	JUDGEMENT			= 21, 
	WORLD 				= 22
}

var SuitColor: Dictionary = {
	CUPS = Color(0.06666667, 0.4117647, 0.74509805),
	WANDS = Color(0.3137255, 0.5882353, 0.0),
	PENTACLES = Color(0.80784315, 0.08235294, 0.11764706),
	SWORDS = Color(0.8862745, 0.7372549, 0.0627451),
	MAJOR = Color(0.65882355, 0.3882353, 0.85490197),
	GOOD = Color(0.90588236, 0.76862746, 0.35686275),
	BAD = Color(0.7176471, 0.0, 0.011764706)
}

var PanelColor: Dictionary = {
	GOOD = Color(0.0627451, 0.32156864, 0.0),
	BAD = Color(0.5882353, 0.0, 0.007843138)
							 }

var GrowthType: Dictionary = {
	LINEAR = LinearGrowth.new(),
	SUPERLINEAR = SuperlinearGrowth.new(),
	EXPONENTIAL = ExponentialGrowth.new()
							 }

enum Operation {ADD, SUBTRACT, MULTIPLY, DIVIDE}
