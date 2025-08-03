extends TextureButton

@export var upgrade_controller : UpgradesController
@export var upgrade_type : DataStructures.UpgradeData.UpgradeType
@onready var border: ColorRect = $MASK/ColorRect

func _ready():
	pressed.connect(_on_pressed)

func select_panel():
	upgrade_controller.set_upgrades(upgrade_type, self)

func select():
	border.show()

func deselect():
	border.hide()

func _on_pressed() -> void:
	select_panel()
	GameManager.event_bus.emit_sfx(DataStructures.SFXType.MENU_TAP)
