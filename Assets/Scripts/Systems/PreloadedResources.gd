extends Node

@export var suit_backgrounds: Dictionary[DataStructures.SuitType, Texture2D]
@export var overlays_by_suit: Dictionary[DataStructures.SuitType, Texture2D]
@export var currency_type: Dictionary[DataStructures.CurrencyType, Texture2D]
@export var numerals: Texture2D
@export var buffs: Texture2D
@export var card_back: Texture2D

var _premade_atlas_textures: Dictionary[int, Texture2D]
var _premade_numerals: Dictionary[int, Texture2D]
var _premade_buffs: Dictionary[DataStructures.SuitType, Dictionary]


## Returns "background", "overlay" and "numeral" if applicable
func get_card_texture(card: Card) -> Dictionary[String, Texture2D]:
	var output: Dictionary[String,Texture2D] = {}
	output["background"] = suit_backgrounds[card.suit]
	output["overlay"] = _get_overlay(card)
	output["numeral"] = get_numeral(card.id - 1) if card.suit == DataStructures.SuitType.MAJOR else null

	return output

func get_upgrade_background(suit: UpgradeData.UpgradeType) -> Texture2D:
	if suit == UpgradeData.UpgradeType.GENERAL:
		return card_back
	return suit_backgrounds[suit]
	
	
func _get_overlay(card: Card) -> Texture2D:
	if _premade_atlas_textures.keys().has(card.id):
		return _premade_atlas_textures[card.id]
	var atlas: AtlasTexture = AtlasTexture.new()
	if !overlays_by_suit.keys().has(card.suit):
		atlas.atlas = null
	else:
		atlas.atlas = overlays_by_suit[card.suit]
	
	var id: int = card.id % GameConstants.SUIT_CARD_COUNT
	# art is currently 400 x 699 and atlas is produced in horizontal row
	atlas.region = Rect2(GameConstants.CARD_ART_WIDTH*(id-1), 0, GameConstants.CARD_ART_WIDTH, GameConstants.CARD_ART_HEIGHT)
	_premade_atlas_textures[card.id] = atlas
	return atlas
	
func get_numeral(id_num: int) -> Texture2D:
	if _premade_numerals.keys().has(id_num):
		return _premade_numerals[id_num]
	var index: int          = id_num % GameConstants.SUIT_CARD_COUNT
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = numerals
	atlas.region = Rect2((index)*64,0,64,64)
	_premade_numerals[id_num] = atlas
	return atlas
		
func get_buff_icon(suit: DataStructures.SuitType, type_or_id) -> Texture2D:
	if _premade_buffs.is_empty():
		_create_buff_dict()
	
	# For major cards, use the card's numeral/art instead of buff atlas
	if suit == DataStructures.SuitType.MAJOR:
		# For major cards, type_or_id is the major card ID
		# Use the existing get_numeral method to get the card's texture
		return get_numeral(type_or_id)
	else:
		# For regular suits, type_or_id is a BuffType
		return _premade_buffs[suit][type_or_id]
		
func _create_buff_dict() -> void:
	for suit in DataStructures.SuitType.values():
		if suit == DataStructures.SuitType.NONE:
			continue
		var suit_dict: Dictionary = {}
		for buff_type in DataStructures.BuffType.values():
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = buffs
			atlas.region = Rect2(64*buff_type,64*suit,64,64)
			suit_dict[buff_type] = atlas
		_premade_buffs[suit] = suit_dict