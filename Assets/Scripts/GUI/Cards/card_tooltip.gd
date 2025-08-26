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
	EventBus.tooltip_requested.connect(_on_tooltip_requested)


# Cleanup on exit
func _exit_tree() -> void:
	_disconnect_signals()

# Disconnect signals to prevent memory leaks
func _disconnect_signals() -> void:
	EventBus.tooltip_requested.disconnect(_on_tooltip_requested)
#endregion

#region Tooltip Display
# Handle tooltip request from EventBus - Smart translator with layer and object type support
func _on_tooltip_requested(object: Variant, layer: DataStructures.GameLayer) -> void:
	if object:
		# Route to appropriate tooltip handler based on game layer
		match layer:
			DataStructures.GameLayer.DECK:
				_display_deck_tooltip(object)
			DataStructures.GameLayer.PACK:
				_display_pack_tooltip(object)  # Future implementation
			DataStructures.GameLayer.BONES:
				_display_bones_tooltip(object)  # Future implementation
			DataStructures.GameLayer.POUCH:
				_display_pouch_tooltip(object)  # Future implementation
			_:
				# Default to deck layer for backwards compatibility
				_display_deck_tooltip(object)

# Display tooltip for deck layer (current tarot system - expects Card objects)
func _display_deck_tooltip(object: Variant) -> void:
	if object is Card:
		display_card_tooltip(object as Card)
	else:
		push_warning("TooltipSystem: DECK layer expected Card object, got: " + str(type_string(typeof(object))))

# Future implementations for other prestige layers
func _display_pack_tooltip(object: Variant) -> void:
	# TODO: Implement pack layer tooltip formatting
	# Could handle Rune, Symbol, or other pack-specific objects
	_display_deck_tooltip(object)  # Fallback to deck for now

func _display_bones_tooltip(object: Variant) -> void:
	# TODO: Implement bones layer tooltip formatting  
	# Could handle Bone, Artifact, or other bones-specific objects
	_display_deck_tooltip(object)  # Fallback to deck for now

func _display_pouch_tooltip(object: Variant) -> void:
	# TODO: Implement pouch layer tooltip formatting
	# Could handle Charm, Item, or other pouch-specific objects
	_display_deck_tooltip(object)  # Fallback to deck for now

# Display tooltip for a specific card
func display_card_tooltip(card: Card) -> void:
	_set_card_visuals(card)
	_set_card_information(card)
	_set_card_descriptions(card)
	show()

# Configure the visual elements of the card
func _set_card_visuals(card: Card) -> void:
	var textures = PreloadedResources.get_card_texture(card)
	
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
	
	# Always get fresh card information from Tools
	if card.value > GameConstants.FACE_CARD_THRESHOLD:
		card_title.text = Tools.get_card_title(card)
	else:
		card_title.text = "Basic Suit Effect"

	# Set suit-appropriate color (always fresh from card.suit)
	var suit_color = _get_suit_color(card.suit)
	card_title.add_theme_color_override("default_color", suit_color)

# Set the card and suit descriptions
func _set_card_descriptions(card: Card) -> void:
	# Use Tools methods for consistent access to card and suit descriptions
	card_desc.text = Tools.get_card_description(card, true)
	suit_desc.text = Tools.get_suit_description(card, true)

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
