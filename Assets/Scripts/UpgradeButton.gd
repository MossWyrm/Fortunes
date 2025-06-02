extends Button

var main_parent: Node
@onready var cost_text: Node 	= $Cost
@onready var title_desc: Node 	= $MarginContainer/Title_Desc
@onready var cvc: CVC 			= GM.cv_manager


var passed_time: float   = 0
var required_time: float = 1
var upgrade_value: int   = 0
var upgrade: BaseUpgrade


func _ready():
	pressed.connect(_purchase)

func _currency_check(currency):
	if currency >= upgrade._cost():
		disabled = false
	else:
		disabled = true

func _set_button(upgrade_input):
	upgrade = upgrade_input
	_update_button()

func _update_button():
	cost_text.text = "Cost: " + str(upgrade._cost())
	var text_to_display = "%s \n %s"
	title_desc.text = text_to_display % [upgrade.title, upgrade.description]

func _purchase():
	if Stats.current_currency >= upgrade._cost():
		cvc._remove_currency(upgrade._cost())	
		upgrade.times_purchased +=1
		upgrade._trigger()
		_update_button()
		
