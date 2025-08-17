extends Control
## Upgrade button component for purchase interface
##
## Handles the display and interaction for individual upgrades in the upgrade shop.
## Integrates with the new EventBus architecture for currency and upgrade management.

#region Node References
@onready var cost_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Cost
@onready var currency_icon: TextureRect = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/CurrencyImage
@onready var title_description: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/Title_Desc
@onready var progress_slider: ColorRect = $MASK/ColorRect
@onready var card_background: TextureRect = $MarginContainer/HBoxContainer/CardBack
@onready var card_overlay: TextureRect = $MarginContainer/HBoxContainer/CardBack/CardOverlay
#endregion

#region Properties
var upgrade_data: UpgradeData
var is_locked: bool = false

# Hold-to-purchase mechanics
var is_holding: bool = false
var hold_timer: float = 0.0
var hold_delay: float = GameConstants.HOLD_TO_PURCHASE_DELAY
#endregion

#region Initialization
func _ready() -> void:
	_connect_event_bus()

# Connect to EventBus signals using SignalManager for safety
func _connect_event_bus() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(
			GameManager.game_state.event_bus.currency_updated, 
			_on_currency_updated, 
			"UpgradeButton currency updates"
		)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(
			GameManager.game_state.event_bus.currency_updated,
			_on_currency_updated,
			"UpgradeButton currency updates"
		)
#endregion

#region Update Loop
func _process(delta: float) -> void:
	if visible:
		_handle_purchase_progress(delta)
		_update_button_state()
#endregion

#region Setup
# Configure the button with upgrade data
func setup_upgrade_button(upgrade: UpgradeData, upgrade_type: UpgradeData.UpgradeType) -> void:
	upgrade_data = upgrade
	_setup_visuals(upgrade_type)
	_update_display()

# Setup visual elements
func _setup_visuals(upgrade_type: UpgradeData.UpgradeType) -> void:
	if not upgrade_data:
		return
	
	# Set background based on upgrade type
	var background_type = upgrade_type if upgrade_type != UpgradeData.UpgradeType.PACK else UpgradeData.UpgradeType.GENERAL
	card_background.texture = get_node("/root/PreloadedResources").get_upgrade_background(background_type)
	
	# Set overlay if upgrade has associated card
	if upgrade_data.associated_card_id > 0:
		_setup_card_overlay()
	else:
		_hide_card_overlay()

# Setup card overlay for upgrades with associated cards
func _setup_card_overlay() -> void:
	if ValidationUtils.has_deck_manager():
		var card = GameManager.game_state.deck_manager.get_card(upgrade_data.associated_card_id)
		if card:
			var textures = get_node("/root/PreloadedResources").get_card_texture(card)
			card_overlay.texture = textures.get("overlay")
			card_overlay.show()

# Hide card overlay
func _hide_card_overlay() -> void:
	card_overlay.hide()
	card_overlay.texture = null
#endregion
	
#region Display Management
# Update button display based on current state
func _update_display() -> void:
	if not upgrade_data:
		return
	
	_update_currency_display()
	_update_cost_display()
	_update_title_description()

# Update currency icon
func _update_currency_display() -> void:
	currency_icon.texture = get_node("/root/PreloadedResources").currency_type[upgrade_data.currency_type]

# Update cost text and color
func _update_cost_display() -> void:
	if upgrade_data.is_max_level():
		cost_label.text = "~ Fully Upgraded ~"
		cost_label.add_theme_color_override("font_color", Color.GRAY)
	else:
		var cost_text = "Cost: " + get_node("/root/Tools").get_shorthand(upgrade_data.cost)
		cost_label.text = cost_text
		_update_cost_color()

# Update cost text color based on affordability
func _update_cost_color() -> void:
	var can_afford = _can_afford_upgrade()
	var color = DataStructures.core_color.GOOD if can_afford else DataStructures.core_color.BAD
	cost_label.add_theme_color_override("font_color", color)

# Update title and description
func _update_title_description() -> void:
	var display_text = DescriptionFormatter.format_title_description(upgrade_data.title, upgrade_data.description)
	title_description.text = display_text

# Update button interactive state
func _update_button_state() -> void:
	if not upgrade_data:
		return
	
	is_locked = not _can_afford_upgrade() or upgrade_data.is_max_level()

# Check if player can afford the upgrade
func _can_afford_upgrade() -> bool:
	if not upgrade_data:
		return false
	
	var current_currency = _get_current_currency()
	return current_currency >= upgrade_data.cost

# Get current currency amount
func _get_current_currency() -> int:
	if ValidationUtils.has_stats():
		match upgrade_data.currency_type:
			DataStructures.CurrencyType.CLAIRVOYANCE: 
				return GameManager.game_state.stats.clairvoyance
			DataStructures.CurrencyType.PACK: 
				return GameManager.game_state.stats.packs
			_: 
				return 0
	return 0
#endregion

#region Event Handlers
# Handle currency update events
#region Display Updates
# Update all display elements
func _update_display() -> void:
	if not upgrade_data:
		return
	
	_update_currency_icon()
	_update_cost_display()
	_update_title_description()

# Update currency icon
func _update_currency_icon() -> void:
	if upgrade_data:
		currency_icon.texture = get_node("/root/PreloadedResources").currency_type.get(upgrade_data.currency_type)

# Update cost display and affordability
func _update_cost_display() -> void:
	if upgrade_data.is_fully_upgraded:
		cost_label.text = "~ Fully Upgraded ~"
		cost_label.add_theme_color_override("font_color", Color.GRAY)
		is_locked = true
	else:
		var cost_text = "Cost: " + get_node("/root/Tools").get_shorthand(upgrade_data.cost)
		cost_label.text = cost_text
		_update_affordability()

# Update button state based on affordability
func _update_button_state() -> void:
	if not upgrade_data:
		return
	
	_update_affordability()

# Check if player can afford the upgrade
func _update_affordability() -> void:
	if not upgrade_data:
		return
	
	var current_currency = _get_current_currency()
	var can_afford = current_currency >= upgrade_data.cost and not upgrade_data.is_fully_upgraded
	
	if can_afford:
		cost_label.add_theme_color_override("font_color", DataStructures.core_color.GOOD)
		is_locked = false
	else:
		cost_label.add_theme_color_override("font_color", DataStructures.core_color.BAD)
		is_locked = true

# Update title and description text
func _update_title_description() -> void:
	if upgrade_data and title_description:
		title_description.text = DescriptionFormatter.format_title_description(upgrade_data.title, upgrade_data.description)

# Get current currency amount for this upgrade's currency type
func _get_current_currency() -> int:
	if not upgrade_data:
		return 0
	
	if ValidationUtils.has_stats():
		match upgrade_data.currency_type:
			DataStructures.CurrencyType.CLAIRVOYANCE:
				return GameManager.game_state.stats.clairvoyance
			DataStructures.CurrencyType.PACK:
				return GameManager.game_state.stats.packs
			_:
			return 0
	
	return 0
#endregion
#endregion

#region Purchase System
# Execute the upgrade purchase
func _purchase_upgrade() -> void:
	if not upgrade_data or is_locked:
		return
	
	# Emit currency update through EventBus
	if ValidationUtils.has_event_bus():
		GameManager.game_state.event_bus.emit_currency_updated(
			-upgrade_data.cost,
			upgrade_data.currency_type
		)
		
		# Emit upgrade purchase event
		GameManager.game_state.event_bus.emit_upgrade_purchased(upgrade_data)
	
	# Update display after purchase
	_update_display()

# Handle purchase progress during hold
func _handle_purchase_progress(delta: float) -> void:
	if is_locked or not is_holding:
		return
	
	hold_timer += delta
	
	if hold_timer >= hold_delay:
		_complete_purchase()
	else:
		_update_progress_display()

# Complete the purchase and reset state
func _complete_purchase() -> void:
	hold_timer = 0.0
	_set_progress_percent(0.0)
	_purchase_upgrade()

# Update progress slider display
func _update_progress_display() -> void:
	var progress = hold_timer / hold_delay
	_set_progress_percent(min(progress, 1.0))

# Set progress slider percentage
func _set_progress_percent(percent: float) -> void:
	progress_slider.scale.x = percent
#endregion

#region Input Handling
# Handle GUI interaction for hold-to-purchase
func on_gui_interact(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_click"):
		_start_hold()
	
	if Input.is_action_just_released("ui_click"):
		_end_hold()

# Start hold timer
func _start_hold() -> void:
	is_holding = true
	hold_timer = 0.0

# End hold and reset state
func _end_hold() -> void:
	_set_progress_percent(0.0)
	is_holding = false
	hold_timer = 0.0
#endregion