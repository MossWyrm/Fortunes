extends TextureButton

@export var upgrade_controller : UpgradesController
@export var upgrade_type : ID.UpgradeType
@onready var border: ColorRect = $MASK/ColorRect

func _ready():
	pressed.connect(select_panel)

func select_panel():
	upgrade_controller.set_upgrades(upgrade_type, self)


func select():
	border.show()

func deselect():
	border.hide()