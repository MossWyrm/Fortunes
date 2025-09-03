extends TextureButton
class_name DeckCreatorNavButton

## Deck selection navigation button

@export var panel_navigator: DeckCreatorNavigator
# Suit number mapping:
# 0 - Cups
# 1 - Wands  
# 2 - Pentacles
# 3 - Swords
# 4 - Majors
@export var suit_number: int
@onready var border: ColorRect = $MASK/ColorRect

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	if panel_navigator:
		panel_navigator.open_panel(self, suit_number)

func select() -> void:
	if border:
		border.show()

func deselect() -> void:
	if border:
		border.hide()
