extends TextureButton
class_name DeckSelectNavButton
## Navigation button for deck creator suit panels
##
## Represents a clickable button that switches between different suit panels
## in the deck creator interface. Shows visual feedback when selected.

#region Export Properties
@export var deck_creator: deck_creator_navigator
# Suit number mapping:
# 0 - Cups
# 1 - Wands  
# 2 - Pentacles
# 3 - Swords
# 4 - Majors
@export var suit_number: int
#endregion

#region Node References
@onready var border: ColorRect = $MASK/ColorRect
#endregion

#region Initialization
func _ready() -> void:
	_connect_signals()

# Connect button signals
func _connect_signals() -> void:
	pressed.connect(_on_button_pressed)
#endregion

#region Input Handling
# Handle button press and switch to associated panel
func _on_button_pressed() -> void:
	if deck_creator:
		deck_creator.open_panel(self, suit_number)
#endregion

#region Visual State Management
# Show selection border
func select() -> void:
	if border:
		border.show()

# Hide selection border
func deselect() -> void:
	if border:
		border.hide()
#endregion