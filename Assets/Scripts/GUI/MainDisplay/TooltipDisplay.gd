extends Control

## Card tooltip display component
## Shows detailed information about cards including visuals, descriptions,
## and lock status. Accessed via EventBus

@onready var locked_overlay: Control = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/MASK
@onready var card_face: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace
@onready var card_overlay: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/CardOverlay
@onready var card_title: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardTitle
@onready var card_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CardDesc
@onready var suit_desc: RichTextLabel = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/SuitDesc
@onready var numeral: TextureRect = $PanelContainer/CardInfo/Details/MarginContainer/VBoxContainer/HBoxContainer/Panel/CardFace/Numeral

#region Initialization
func _ready() -> void:
	_connect_event_bus()

# Connect to the new EventBus architecture
func _connect_event_bus() -> void:
	EventBus.tooltip_requested.connect(_on_tooltip_requested)
#endregion

#region Tooltip Display
# Handle tooltip request from EventBus - Smart translator with layer and object type support
func _on_tooltip_requested(object: Variant, layer: DataStructures.GameLayer, as_buff: bool = false) -> void:
	if object:
		# Route to appropriate tooltip handler based on game layer
		match layer:
			DataStructures.GameLayer.DECK:
				_display_deck_tooltip(object, as_buff)
			DataStructures.GameLayer.PACK:
				_display_pack_tooltip(object)  # Future implementation
			DataStructures.GameLayer.BONES:
				_display_bones_tooltip(object)  # Future implementation
			DataStructures.GameLayer.POUCH:
				_display_pouch_tooltip(object)  # Future implementation
			_:
				# Default to deck layer for backwards compatibility
				_display_deck_tooltip(object)

func _display_deck_tooltip(object: Variant, as_buff: bool = false) -> void:
	if object is Card:
		display_card_tooltip(object as Card, as_buff)
	else:
		DebugManager.print_ui_displays("TooltipSystem: DECK layer expected Card object, got: " + str(type_string(typeof(object))))

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

func display_card_tooltip(card: Card, as_buff: bool = false) -> void:
	_set_card_visuals(card)
	_set_card_information(card, as_buff)
	_set_card_descriptions(card)
	show()

func _set_card_visuals(card: Card) -> void:
	var textures = PreloadedResources.get_card_texture(card)
	card_face.texture = textures.get("background")
	card_overlay.texture = textures.get("overlay")
	var numeral_texture = textures.get("numeral")
	if numeral_texture:
		numeral.texture = numeral_texture
		numeral.show()
	else:
		numeral.hide()

func _set_card_information(card: Card, as_buff: bool = false) -> void:
	locked_overlay.visible = not card.is_unlocked
	if as_buff and card.value <= GameConstants.FACE_CARD_THRESHOLD and card.suit != DataStructures.SuitType.MAJOR:
		card_title.text = "Basic Suit Effect"
	else:
		card_title.text = Tools.get_card_title(card)
	var suit_color = _get_suit_color(card.suit)
	card_title.add_theme_color_override("default_color", suit_color)

func _set_card_descriptions(card: Card) -> void:
	card_desc.text = Tools.get_card_description(card, true)
	suit_desc.text = Tools.get_suit_description(card, true)

func _get_suit_color(suit: DataStructures.SuitType) -> Color:
	var suit_name = DataStructures.SuitType.keys()[suit]
	return DataStructures.core_color.get(suit_name, Color.WHITE)
#endregion
