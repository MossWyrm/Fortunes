extends RefCounted
class_name NavigationManager

var creator_panel: Node
var upgrade_panel: Node

enum PanelType {
	CREATOR,
	UPGRADE
}

func open_panel(type: PanelType) -> void:
	match type:
		PanelType.CREATOR:
			creator_panel.show()
		PanelType.UPGRADE:
			upgrade_panel.show()
