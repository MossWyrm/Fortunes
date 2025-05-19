extends Node

var currently_active = false
var animator : AnimationPlayer

func _ready():
	Events.upgrade_menu_toggle.connect(toggle_upgrade_panel)
	animator = $UpgradeAnimator

func toggle_upgrade_panel(is_displayed : bool):
	edit_animations()
	if(is_displayed && currently_active == false):
		animator.play("UpgradePanelAnimationShow")
		currently_active = true
	elif !is_displayed && currently_active == true:
		animator.play("UpgradePanelAnimationHide")
		currently_active = false

func edit_animations():
	var current_size = self.get_parent().size.x
	animator.get_animation("UpgradePanelAnimationShow").track_set_key_value(0,0,current_size)
	animator.get_animation("UpgradePanelAnimationHide").track_set_key_value(0,1,current_size)
