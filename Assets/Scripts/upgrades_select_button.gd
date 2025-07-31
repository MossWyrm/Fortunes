extends TextureButton

@export var upgrade_controller : UpgradesController
@export var upgrade_type : ID.UpgradeType
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
	Events.emit_sfx(AudioManager.SFX.MENU_TAP)
