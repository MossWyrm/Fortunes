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
func get_card_texture(card: DataStructures.Card) -> Dictionary[String, Texture2D]:
	var output: Dictionary[String,Texture2D] = {}
	output["background"] = suit_backgrounds[card.card_suit]
	output["overlay"] = _get_overlay(card)
	output["numeral"] = get_numeral(card.card_id_num)

	return output

func get_upgrade_background(suit: DataStructures.UpgradeData.UpgradeType) -> Texture2D:
	if suit == DataStructures.UpgradeData.UpgradeType.GENERAL:
		return card_back
	return suit_backgrounds[suit]
	
	
func _get_overlay(card: DataStructures.Card) -> Texture2D:
	if _premade_atlas_textures.keys().has(card.card_id_num):
		return _premade_atlas_textures[card.card_id_num]
	var atlas: AtlasTexture = AtlasTexture.new()
	if !overlays_by_suit.keys().has(card.card_suit):
		atlas.atlas = null
	else:
		atlas.atlas = overlays_by_suit[card.card_suit]
	
	var id: int = card.card_id_num % 100
	# art is currently 400 x 699 and atlas is produced in horizontal row
	atlas.region = Rect2(400*(id-1),0,400,699)
	_premade_atlas_textures[card.card_id_num] = atlas
	return atlas
	
func get_numeral(id_num: int) -> Texture2D:
	if _premade_numerals.keys().has(id_num):
		return _premade_numerals[id_num]
	if id_num > 500:
		var index: int          = id_num % 100
		var atlas: AtlasTexture = AtlasTexture.new()
		atlas.atlas = numerals
		atlas.region = Rect2((index-1)*64,0,64,64)
		_premade_numerals[id_num] = atlas
		return atlas
	else:
		return null
		
func get_buff_icon(suit: DataStructures.SuitType, type: ID.BuffType) -> Texture2D:
	if _premade_buffs.is_empty():
		_create_buff_dict()
	return _premade_buffs[suit][type]
		
func _create_buff_dict() -> void:
	for suit in DataStructures.SuitType.values():
		if suit == DataStructures.SuitType.NONE:
			continue
		var suit_dict: Dictionary = {}
		for buff_type in ID.BuffType.values():
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = buffs
			atlas.region = Rect2(64*buff_type,64*suit,64,64)
			suit_dict[buff_type] = atlas
		_premade_buffs[suit] = suit_dict
		
			
		