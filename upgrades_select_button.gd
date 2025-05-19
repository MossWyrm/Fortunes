extends TextureButton

@export var upgrade_controller : UpgradesController

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
	upgrade_controller.set_upgrades(suit_number)
