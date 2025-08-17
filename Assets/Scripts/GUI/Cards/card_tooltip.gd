extends Control
## Card tooltip display component
##
## Shows detailed information about cards including visuals, descriptions,
## and lock status. Integrates with the new EventBus architecture.

#region Node References
@onready var locked_overlay: Control = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/MASK
@onready var card_face: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace
@onready var card_overlay: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/CardOverlay
@onready var card_title: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardTitle
@onready var card_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardDesc
@onready var suit_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/SuitDesc
@onready var numeral: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/Numeral
#endregion

#region Initialization
func _ready() -> void:
	_connect_event_bus()

# Connect to the new EventBus architecture
func _connect_event_bus() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_connect(
			GameManager.game_state.event_bus.tooltip_requested,
			_on_tooltip_requested,
			"CardTooltip tooltip_requested"
		)

# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	if ValidationUtils.has_event_bus():
		SignalManager.safe_disconnect(
			GameManager.game_state.event_bus.tooltip_requested,
			_on_tooltip_requested,
			"CardTooltip tooltip_requested"
		)
#endregion

#region Tooltip Display
# Handle tooltip request from EventBus
func _on_tooltip_requested(tooltip_data: TooltipData) -> void:
	if tooltip_data and tooltip_data.card:
		display_card_tooltip(tooltip_data.card)

# Display tooltip for a specific card
func display_card_tooltip(card: Card) -> void:
	_set_card_visuals(card)
	_set_card_information(card)
	_set_card_descriptions(card)
	show()

# Configure the visual elements of the card
func _set_card_visuals(card: Card) -> void:
	var textures = get_node("/root/PreloadedResources").get_card_texture(card)
	
	# Set main textures
	card_face.texture = textures.get("background")
	card_overlay.texture = textures.get("overlay")
	
	# Handle numeral display
	var numeral_texture = textures.get("numeral")
	if numeral_texture:
		numeral.texture = numeral_texture
		numeral.show()
	else:
		numeral.hide()

# Set the card's title, color, and lock status
func _set_card_information(card: Card) -> void:
	# Show/hide lock overlay
	locked_overlay.visible = not card.is_unlocked
	
	# Set card title
	card_title.text = card.card_title
	
	# Set suit-appropriate color
	var suit_color = _get_suit_color(card.card_suit)
	card_title.add_theme_color_override("default_color", suit_color)

# Set the card and suit descriptions
func _set_card_descriptions(card: Card) -> void:
	var description_data = get_node("/root/CardDescriptions").get_description(card, true)
	card_desc.text = description_data.get("card", "")
	suit_desc.text = description_data.get("suit", "")

# Get the appropriate color for a card suit
func _get_suit_color(suit: DataStructures.SuitType) -> Color:
	var suit_name = DataStructures.SuitType.keys()[suit]
	return DataStructures.core_color.get(suit_name, Color.WHITE)
#endregion

#region Buff Tooltip (Commented)
## Function for buff tooltips - may need to be reimplemented
## based on new architecture requirements
# func display_for_buff(suit: DataStructures.SuitType, buff_type: DataStructures.BuffType, card_number: int) -> void:
# 	"""Display tooltip for buff cards"""
# 	var card_id = _calculate_buff_card_id(suit, buff_type, card_number)
# 	if ValidationUtils.has_deck_manager():
# 		var card = GameManager.game_state.deck_manager.get_card(card_id)
# 		if card:
# 			display_card_tooltip(card)
# 
# func _calculate_buff_card_id(suit: DataStructures.SuitType, buff_type: DataStructures.BuffType, card_number: int) -> int:
# 	"""Calculate the card ID for buff tooltips"""
# 	if suit == DataStructures.SuitType.MAJOR:
# 		return GameConstants.MAJOR_CARD_THRESHOLD + card_number
# 	else:
# 		return GameConstants.calculate_card_id(suit, buff_type)
#endregion
