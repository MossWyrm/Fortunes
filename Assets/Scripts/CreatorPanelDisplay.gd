extends Node

var currently_active = false
var animator : AnimationPlayer

func _ready():
	Events.creator_menu_toggle.connect(toggle_creator_panel)
	animator = $DeckCreatorPanelAnimator

func toggle_creator_panel(is_displayed : bool):
	edit_animations()
	if(is_displayed && currently_active == false):
		animator.play("CreatorPanelAnimationShow")
		currently_active = true
	elif !is_displayed && currently_active == true:
		animator.play("CreatorPanelAnimationHide")
		currently_active = false

func edit_animations():
	var current_size = 0-self.get_parent().size.x
	animator.get_animation("CreatorPanelAnimationShow").track_set_key_value(0,0,current_size)
	animator.get_animation("CreatorPanelAnimationHide").track_set_key_value(0,1,current_size)
