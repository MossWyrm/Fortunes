extends Control
class_name UpgradeButton

var main_parent: Node
@onready var cost_text: Label 	= $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Cost
@onready var currency_image: TextureRect 	= $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrencyImage
@onready var title_desc: Node 	= $MarginContainer/HBoxContainer/VBoxContainer/Title_Desc
@onready var cvc: CVC 			= GM.cv_manager
@onready var slider: ColorRect 	= $MASK/ColorRect
@onready var card_back: TextureRect = $MarginContainer/HBoxContainer/CardBack
@onready var card_overlay: TextureRect = $MarginContainer/HBoxContainer/CardBack/CardOverlay


var passed_time: float   = 0
var required_time: float = 1
var upgrade_value: int   = 0
var upgrade: Upgrade
var locked: bool = false
var holding:bool = false
var hold_timer: float = 0
var hold_delay: float = 0.8

var required_currency: int:
	get:
		match upgrade.currency_type:
			ID.CurrencyType.CLAIRVOYANCE: return Stats.clairvoyance
			ID.CurrencyType.PACK: return Stats.packs
			_: return 0

	
func _process(delta: float) -> void:
	if self.visible:
		_check_for_purchase(delta)
		_check_for_button_update()

func set_button(upgrade_input, type: ID.UpgradeType):
	upgrade = upgrade_input
	card_back.texture = ResourceAutoload.get_upgrade_background(type if type != ID.UpgradeType.PACK else ID.UpgradeType.GENERAL)
	if upgrade.id > 0:
		card_overlay.texture = ResourceAutoload.get_card_texture(GM.deck_manager.get_card(upgrade.id))["overlay"]
		card_overlay.show()
	else:
		card_overlay.hide()
		card_overlay.texture = null
	_update_button()

func _check_for_button_update() -> void:
	if upgrade == null:
		return 
	if required_currency >= upgrade.cost && !upgrade.fully_upgraded:
		cost_text.add_theme_color_override("font_color",ID.SuitColor["GOOD"])
		locked = false
	else:
		cost_text.add_theme_color_override("font_color",ID.SuitColor["BAD"])
		locked = true
			
func _update_button():
	currency_image.texture = ResourceAutoload.currency_type[upgrade.currency_type]
	var cost_text_string: String = "Cost: " + Tools.get_shorthand(upgrade.cost)
	var fully_upgraded: String = "~ Fully Upgraded ~"
	cost_text.text = fully_upgraded if upgrade.fully_upgraded else cost_text_string
	title_desc.text = "%s\n%s"% [upgrade.title, upgrade.description]

func _purchase():
	Events.emit_update_currency(-upgrade.cost, upgrade.currency_type)
	upgrade.times_purchased +=1
	upgrade.trigger()
	_update_button()

func set_slider_percent(percent: float) -> void:
	slider.scale.x = percent


func on_gui_interract(_event:InputEvent) -> void:
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
		var percent: float = hold_timer / hold_delay
		set_slider_percent(percent if percent < 1.0 else 1.0)