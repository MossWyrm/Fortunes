extends TextureButton

@export var deck_creator : deck_creator_navigator

##Use different numbers for different suits:
##[codeblock]
## 0 - cups [br]
## 1 - wands [br]	
## 2 - pentacles [br]
## 3 - swords [br]
## 4 - majors
##[/codeblock]
@export var suit_number : int

func _ready():
	pressed.connect(select_panel)

func select_panel():
	deck_creator.open_panel(suit_number)
