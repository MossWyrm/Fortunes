extends Button

var is_menu_shown = false
var defaultText = "Upgrades \n >"

func _ready():
	pressed.connect(toggle_upgrade)
	Events.upgrade_menu_toggle.connect(update_button_text)
	Events.creator_menu_toggle.connect(reset_text)
	text = defaultText

func toggle_upgrade():
	if(is_menu_shown):
		text = defaultText
		is_menu_shown = false
	else:
		text = "X"
		is_menu_shown = true
	Events.emit_upgrade_menu_toggle(is_menu_shown)
	Events.emit_creator_menu_toggle(false)

func update_button_text(shown: bool):
	if !is_menu_shown && shown:
		text = "X"
		is_menu_shown = true
	if is_menu_shown && !shown:
		text = defaultText
		is_menu_shown = false

func reset_text(state : bool):
	if state:
		text = defaultText
		is_menu_shown = false