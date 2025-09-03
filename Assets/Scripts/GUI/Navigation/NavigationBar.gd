extends Control

func open_creator_panel() -> void:
	GameManager.game_state.nav_manager.open_panel(NavigationManager.PanelType.CREATOR)

func open_upgrade_panel() -> void:
	GameManager.game_state.nav_manager.open_panel(NavigationManager.PanelType.UPGRADE)