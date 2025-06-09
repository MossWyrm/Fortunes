extends Node
class_name ResourceIDs

enum Suits {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, NONE = 5}
enum UpgradeType {CUPS = 0, WANDS = 1, PENTACLES = 2, SWORDS = 3, MAJOR = 4, GENERAL = 5}
enum BuffType {GENERAL = 0, PAGE = 1, KNIGHT = 2, QUEEN = 3, KING = 4}
	
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