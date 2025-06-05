extends Control

var main_parent: Node
@onready var cost_text: Node 	= $MarginContainer/HBoxContainer/VBoxContainer/Cost
@onready var title_desc: Node 	= $MarginContainer/HBoxContainer/VBoxContainer/Title_Desc
@onready var cvc: CVC 			= GM.cv_manager
@onready var slider: ColorRect 	= $MASK/ColorRect


var passed_time: float   = 0
var required_time: float = 1
var upgrade_value: int   = 0
var upgrade: BaseUpgrade
var locked: bool = false
var holding:bool = false
var hold_timer: float = 0
var hold_delay: float = 0.8

	
func _process(delta: float) -> void:
	if self.visible:
		_check_for_purchase(delta)
		_check_for_button_update()

func _set_button(upgrade_input):
	upgrade = upgrade_input
	_update_button()

func _check_for_button_update() -> void:
	if upgrade == null:
		return
	if locked:
		if Stats.current_currency >= upgrade._cost():
			cost_text.add_theme_color_override("font_color",ID.SuitColor["GOOD"])
			locked = false
	else:
		if Stats.current_currency < upgrade._cost():
			cost_text.add_theme_color_override("font_color",ID.SuitColor["BAD"])
			locked = true
			
func _update_button():
	cost_text.text = "Cost: " + str(upgrade._cost())
	var text_to_display = "%s\n%s"
	title_desc.text = text_to_display % [upgrade.title, upgrade.description]

func _purchase():
	cvc._remove_currency(upgrade._cost())	
	upgrade.times_purchased +=1
	upgrade._trigger()
	_update_button()

func set_slider_percent(percent: float) -> void:
	slider.scale.x = percent


func on_gui_interract(event:InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		holding = true
	if Input.is_action_just_released("ui_click"):
		set_slider_percent(0.0)
		holding = false
		hold_timer = 0

func _check_for_purchase(delta: float) -> void:
	if locked || !holding:
		return
	hold_timer += delta
	if hold_timer >= hold_delay:
		hold_timer = 0
		set_slider_percent(0.0)
		_purchase()
	else:
		var percent = hold_timer / hold_delay
		set_slider_percent(percent if percent < 1.0 else 1.0)