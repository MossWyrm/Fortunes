class_name UpgradesList
extends RefCounted

## Centralized upgrade definitions using builder pattern for cleaner code
## Each upgrade type has its own section with helper methods to reduce repetition

#region Upgrade Creation Helper
## UNIFIED upgrade creation - one method handles all cases with clear defaults
func _create_upgrade(
	name: String,
	description: String, 
	base_cost: float,
	stat_path: String,
	operation_value: float,
	# Optional parameters with sensible defaults
	operation: UpgradeData.OperationType = UpgradeData.OperationType.ADD,
	growth_type: DataStructures.GrowthType = DataStructures.GrowthType.SLOW_EXPONENTIAL,
	growth_modifier: float = 2.0,
	max_upgrades: int = -1,
	currency_type: DataStructures.CurrencyType = DataStructures.CurrencyType.CLAIRVOYANCE,
	card_id: int = 0
) -> Dictionary:
	return {
		"NAME": name,
		"DESCRIPTION": description,
		"START_COST": base_cost,
		"GROWTH": growth_type,
		"GROWTH_MOD": growth_modifier,
		"STAT": stat_path,
		"STAT_PATH": stat_path,
		"OPERATION": operation,
		"OPERATION_VALUE": operation_value,
		"MAX_UPGRADES": max_upgrades,
		"CURRENCY_TYPE": currency_type,
		"ID": card_id
	}

# Helper for creating pack upgrades with special properties
func _upgrade_pack(name: String, description: String, start_cost: float, stat: String, operation_value, operation: UpgradeData.OperationType, growth: DataStructures.GrowthType = DataStructures.GrowthType.LINEAR, growth_mod: float = 0, max_upgrades: int = 1) -> Dictionary:
	return {
		"NAME": name,
		"DESCRIPTION": description,
		"START_COST": start_cost,
		"GROWTH": growth,
		"GROWTH_MOD": growth_mod,
		"STAT": stat,
		"STAT_PATH": stat,
		"OPERATION": operation,
		"OPERATION_VALUE": operation_value,
		"MAX_UPGRADES": max_upgrades,
		"CURRENCY_TYPE": DataStructures.CurrencyType.PACK
		}
#endregion

#region General Upgrades
#region General Upgrades - LATE-GAME BALANCED
var general_upgrade_values: Dictionary = {
	inversion_chance_modifier = _create_upgrade(
		"Lucky",
		"Cards are 0.5% more likely to appear right-side up.",
		3000.0,
		"inversion_chance_modifier",
		0.005,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.EXPONENTIAL,
		3.5,
		50  # Capped at 25% total bonus - reasonable for late game
	),
	max_deck_size = _create_upgrade(
		"Variety", 
		"Your deck can hold 1 more card.",
		500.0,
		"max_deck_size",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: More cards = exponentially more power
		2.2  # Slower than exponential but faster than linear
	),
	min_deck_size = _create_upgrade(
		"Precision",
		"Your deck can be 1 card smaller.",
		1000.0,
		"min_deck_size", 
		1.0,
		UpgradeData.OperationType.SUBTRACT,
		DataStructures.GrowthType.EXPONENTIAL,
		4.0,
		10  # Keep capped - going too low breaks game balance
	),

	# SYNERGY UPGRADES (Scale with number of majors/suits - become more valuable late-game)
	major_arcana_synergy = _create_upgrade(
		"Arcana Resonance", "Each Major Arcana in your deck increases all other Major effects by 3%.",
		150000.0, "arcana_synergy_multiplier", 1.03,
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.SUPERLINEAR, 4.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 501
	),
	suit_synergy_cups = _create_upgrade(
		"Cup Foundation", "Each Cup card in your deck increases base value of all cards by 2%.",
		80000.0, "cups_base_multiplier", 1.02,
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.SUPERLINEAR, 3.8, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 110
	),
	suit_synergy_wands = _create_upgrade(
		"Wand Foundation", "Each Wand card in your deck increases multiplier effects by 1.5%.",
		85000.0, "wands_multiplier_bonus", 1.015,
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.SUPERLINEAR, 3.8, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 210
	),
	suit_synergy_pentacles = _create_upgrade(
		"Pentacle Foundation", "Each Pentacle card in your deck increases protection effects by 2%.",
		90000.0, "pentacles_protection_bonus", 1.02,
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.SUPERLINEAR, 3.9, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 310
	),
	suit_synergy_swords = _create_upgrade(
		"Sword Foundation", "Each Sword card in your deck increases combo effects by 2.5%.",
		95000.0, "swords_combo_bonus", 1.025,
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.SUPERLINEAR, 4.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 410
	),
}
#endregion

#region Cup Upgrades - REBALANCED FOR PROGRESSION

var cup_upgrade_values: Dictionary = {
	# BASIC PROGRESSION - Percentage scaling for late-game relevance
	cup_basic_value = _create_upgrade(
		"Basic Value",
		"Numbered Cup cards are worth 10% more (multiplicative).",
		1500.0,
		"cup_stats.basic_value_multiplier",  # New multiplicative stat
		1.1,  # 10% increase per upgrade
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.LINEAR,  # Linear cost for percentage benefits
		1.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		110
	),
	cup_basic_quant = _create_upgrade(
		"Basic Quantity",
		"Allows 1 extra copy of each numbered Cup card in your deck.",
		800.0,  # Slightly higher base cost since this is very powerful
		"cup_stats.basic_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Quantity = exponential power
		1.8,  # Moderate scaling for powerful effect
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		110
	),
	
	# BASE VALUE UPGRADES - Foundation stats that get multiplied by percentage bonuses
	cup_basic_value_base = _create_upgrade(
		"Base Value",
		"Cup cards gain +1 base value (before multipliers are applied).",
		500.0,  # Lower cost since these are foundational upgrades
		"cup_stats.basic_value",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,  # Linear scaling for base values
		1.5,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		113
	),
	
	# FACE CARD UPGRADES - High cost since face cards are very powerful
	cup_face_quant = _create_upgrade(
		"Faces Quantity",
		"Allows 1 extra copy of each face Cup card in your deck.",
		3500.0,  # Higher cost since face cards are much more powerful
		"cup_stats.face_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Face card quantity is extremely powerful
		2.2,  # Faster scaling than basic cards
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		114
	),
	
	# CUP-SPECIFIC MECHANICS - Vessels scale exponentially with major effects
	cup_vessel_quant = _create_upgrade(
		"Add Vessel",
		"Gain another vessel to store clairvoyance.",
		8000.0,  # Higher cost since vessels are extremely powerful late-game
		"cup_stats.vessel_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,
		2.8,  # Slightly slower scaling
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		101
	),
	cup_vessel_size = _create_upgrade(
		"Max Vessel Size", 
		"Vessel capacity increases by 25% (multiplicative).",
		1200.0,  # Higher cost but more meaningful effect
		"cup_stats.vessel_size_multiplier",  # New multiplicative stat
		1.25,  # 25% increase - scales with late-game vessel sizes
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.LINEAR,  # Linear cost for % benefits
		1.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		101
	),
	
	# FACE CARD POWER UPGRADES - Late-game scaling focus
	cup_page_mod = _create_upgrade(
		"Page Upgrade",
		"Page of Cups vessel size bonus multiplies by an additional 25%.",
		8000.0,  # Lower base cost but more meaningful effect
		"cup_stats.page_multiplier",  # New multiplicative stat
		1.25,  # 25% multiplication bonus (much more meaningful than +5%)
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,  # Reasonable scaling for % bonuses
		2.2,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		111
	),
	cup_knight_mod = _create_upgrade(
		"Knight Upgrade",
		"Knight of Cups affects 1 additional card.",
		2500.0,  # Lower cost since flat bonuses become less relevant late-game
		"cup_stats.knight_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling for flat bonus
		2.0,  # Slower than before
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		112
	),
	cup_queen_mod = _create_upgrade(
		"Queen Upgrade",
		"Queen of Cups creates 1 additional vessel.",
		5000.0,  # Higher cost since extra vessels are very powerful
		"cup_stats.queen_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Extra vessels scale exponentially
		2.5,  # Aggressive scaling for very powerful effect
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		113
	)
}
#endregion

#region Wand Upgrades - REBALANCED FOR PROGRESSION

var wand_upgrade_values: Dictionary = {
	# BASIC PROGRESSION - Percentage scaling for late-game relevance
	wand_basic_value = _create_upgrade(
		"Basic Value",
		"Numbered Wand cards are worth 10% more (multiplicative).",
		1500.0,
		"wand_stats.basic_value_multiplier",  # New multiplicative stat
		1.1,  # 10% increase per upgrade
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.LINEAR,  # Linear cost for percentage benefits
		1.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		210
	),
	wand_basic_quant = _create_upgrade(
		"Basic Quantity",
		"Allows 1 extra copy of each numbered Wand card in your deck.",
		800.0,  # Slightly higher base cost since this is very powerful
		"wand_stats.basic_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Quantity = exponential power
		1.8,  # Moderate scaling for powerful effect
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		210
	),
	
	# BASE VALUE UPGRADES - Foundation stats that get multiplied by percentage bonuses
	wand_basic_value_base = _create_upgrade(
		"Base Value",
		"Wand cards gain +1 base value (before multipliers are applied).",
		500.0,  # Lower cost since these are foundational upgrades
		"wand_stats.basic_value",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,  # Linear scaling for base values
		1.5,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		213
	),
	
	# FACE CARD QUANTITY - High cost since face cards are very powerful
	wand_face_quant = _create_upgrade(
		"Faces Quantity",
		"Allows 1 extra copy of each face Wand card in your deck.",
		3500.0,  # Higher cost since face cards are much more powerful
		"wand_stats.face_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Face card quantity is extremely powerful
		2.2,  # Faster scaling than basic cards
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		214
	),
	
	# FACE CARD POWER UPGRADES - Balanced for late-game relevance
	wand_page_mod = _create_upgrade(
		"Page Upgrade",
		"Page of Wands triggers 1 additional time.",
		2500.0,  # Lower cost for flat bonus
		"wand_stats.page_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling
		2.2,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		211
	),
	wand_knight_mod = _create_upgrade(
		"Knight Upgrade",
		"Knight of Wands multiplier effect is 50% stronger.",
		10000.0,  # Lower cost but make it multiplicative
		"wand_stats.knight_multiplier",  # New multiplicative stat
		1.5,  # 50% stronger multiplier effect
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.EXPONENTIAL,
		2.2,  # Slower scaling for % bonus
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		212
	),
	wand_queen_mod = _create_upgrade(
		"Queen Upgrade",
		"Queen of Wands value bonus multiplies by an additional 30%.",
		6000.0,  # Lower cost, more meaningful effect
		"wand_stats.queen_multiplier",  # New multiplicative stat
		1.3,  # 30% multiplication bonus
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		213
	),
	wand_king_mod = _create_upgrade(
		"King Upgrade",
		"King of Wands multiplier effect is 40% stronger.",
		15000.0,  # Lower cost but make it multiplicative
		"wand_stats.king_multiplier",  # New multiplicative stat
		1.4,  # 40% stronger multiplier effect
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.EXPONENTIAL,
		2.4,  # Slower scaling for % bonus
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		214
	)
}
#endregion

#region Pentacle Upgrades - REBALANCED FOR PROGRESSION

var pent_upgrade_values: Dictionary = {
	# BASIC PROGRESSION - Percentage scaling for late-game relevance
	pent_basic_value = _create_upgrade(
		"Basic Value",
		"Numbered Pentacle cards are worth 10% more (multiplicative).",
		1500.0,
		"pent_stats.basic_value_multiplier",  # New multiplicative stat
		1.1,  # 10% increase per upgrade
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.LINEAR,  # Linear cost for percentage benefits
		1.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		310
	),
	pent_basic_quant = _create_upgrade(
		"Basic Quantity",
		"Allows 1 extra copy of each numbered Pentacle card in your deck.",
		800.0,  # Slightly higher base cost since this is very powerful
		"pent_stats.basic_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Quantity = exponential power
		1.8,  # Moderate scaling for powerful effect
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		310
	),
	
	# BASE VALUE UPGRADES - Foundation stats that get multiplied by percentage bonuses
	pent_basic_value_base = _create_upgrade(
		"Base Value",
		"Pentacle cards gain +1 base value (before multipliers are applied).",
		500.0,  # Lower cost since these are foundational upgrades
		"pent_stats.basic_value",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,  # Linear scaling for base values
		1.5,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		313
	),
	
	# FACE CARD QUANTITY - High cost since face cards are very powerful
	pent_face_quant = _create_upgrade(
		"Faces Quantity",
		"Allows 1 extra copy of each face Pentacle card in your deck.",
		3500.0,  # Higher cost since face cards are much more powerful
		"pent_stats.face_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Face card quantity is extremely powerful
		2.2,  # Faster scaling than basic cards
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		314
	),
	
	# FACE CARD POWER UPGRADES - Balanced for late-game scaling
	pent_page_mod = _create_upgrade(
		"Page Upgrade",
		"Page of Pentacles protection multiplier is 35% stronger.",
		4500.0,  # Higher cost for meaningful effect
		"pent_stats.page_multiplier",  # New multiplicative stat
		1.35,  # 35% stronger protection multiplier (much more meaningful)
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		311
	),
	pent_knight_mod = _create_upgrade(
		"Knight Upgrade",
		"Knight of Pentacles grants 1 extra protection use.",
		2000.0,  # Lower cost for flat bonus
		"pent_stats.knight_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling
		2.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		312
	),
	pent_queen_mod = _create_upgrade(
		"Queen Upgrade",
		"Queen of Pentacles flips 1 additional card.",
		1800.0,  # Lower cost for flat bonus
		"pent_stats.queen_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling
		1.8,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		313
	),
	pent_king_mod = _create_upgrade(
		"King Upgrade",
		"King of Pentacles grants 1 extra protection charge.",
		12000.0,  # Lower cost but still expensive for powerful effect
		"pent_stats.king_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Protection charges scale well
		2.3,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		314
	)
}
#endregion

#region Sword Upgrades - REBALANCED FOR PROGRESSION
var sword_upgrade_values: Dictionary = {
	# BASIC PROGRESSION - Percentage scaling for late-game relevance
	sword_basic_value = _create_upgrade(
		"Basic Upgrade",
		"Numbered Sword cards are worth 10% more (multiplicative).",
		1500.0,
		"sword_stats.basic_value_multiplier",  # New multiplicative stat
		1.1,  # 10% increase per upgrade
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.LINEAR,  # Linear cost for percentage benefits
		1.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		410
	),
	sword_basic_quant = _create_upgrade(
		"Basic Quantity",
		"Allows 1 extra copy of each numbered Sword card in your deck.",
		800.0,  # Slightly higher base cost since this is very powerful
		"sword_stats.basic_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Quantity = exponential power
		1.8,  # Moderate scaling for powerful effect
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		410
	),
	
	# BASE VALUE UPGRADES - Foundation stats that get multiplied by percentage bonuses
	sword_basic_value_base = _create_upgrade(
		"Base Value",
		"Sword cards gain +1 base value (before multipliers are applied).",
		500.0,  # Lower cost since these are foundational upgrades
		"sword_stats.basic_value",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,  # Linear scaling for base values
		1.5,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		413
	),
	
	# FACE CARD QUANTITY - High cost since face cards are very powerful
	sword_face_quant = _create_upgrade(
		"Faces Quantity",
		"Allows 1 extra copy of each face Sword card in your deck.",
		3500.0,  # Higher cost since face cards are much more powerful
		"sword_stats.face_max_quantity",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Changed: Face card quantity is extremely powerful
		2.2,  # Faster scaling than basic cards
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		414
	),

	# SPECIAL SWORD MECHANICS
	sword_knight_super = _create_upgrade(
		"Knight Super Upgrade",
		"Once purchased, allows majors to be included in the Knight's effect pool. Game-changing upgrade!",
		25000.0,
		"sword_stats.knight_super",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,
		1.0,
		1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		412
	),

	# FACE CARD POWER UPGRADES - Balanced for late-game scaling
	sword_page_mod = _create_upgrade(
		"Page Upgrade",
		"Page of Swords grants 1 extra charge.",
		2200.0,  # Lower cost for flat bonus
		"sword_stats.page_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling
		2.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		411
	),
	sword_page_mult = _create_upgrade(
		"Page Multiplier",
		"Page of Swords combo multiplier bonus is 50% stronger.",
		6000.0,  # Lower cost but make it multiplicative
		"sword_stats.page_multiplier_bonus",  # New multiplicative stat
		1.5,  # 50% stronger combo multiplier
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		2.0,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		411
	),
	sword_knight_mod = _create_upgrade(
		"Knight Upgrade",
		"Knight of Swords affects cards 1 value higher.",
		7000.0,  # Lower cost for flat bonus
		"sword_stats.knight_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Moderate scaling
		2.2,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		412
	),
	sword_queen_mod = _create_upgrade(
		"Queen Upgrade",
		"Combo point values are 25% higher.",
		5500.0,  # Lower cost but make it multiplicative
		"sword_stats.queen_multiplier",  # New multiplicative stat
		1.25,  # 25% higher combo values
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		1.8,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		413
	),
	sword_king_mod = _create_upgrade(
		"King Upgrade",
		"King of Swords protects combo 1 additional time.",
		3000.0,  # Lower cost for flat bonus
		"sword_stats.king_modifier",
		1.0,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.SUPERLINEAR,  # Protection is valuable but not exponential
		2.5,
		-1,
		DataStructures.CurrencyType.CLAIRVOYANCE,
		414
	)
}
#endregion

#region Major Upgrades - PROPERLY REBALANCED SYSTEM  
var major_upgrade_values: Dictionary = {
	# DECK MANAGEMENT (Keep expensive as intended)
	major_quant_deck = _create_upgrade(
		"Many Majors", "Allows 1 extra Major Arcana slot in your deck.",
		50000.0, "major_stats.quantity_per_deck", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 4.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 0
	),
	major_quant_card = _create_upgrade(
		"Carbon Copies", "Allows 1 extra copy of each Major Arcana.", 
		75000.0, "major_stats.quantity_per_card", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 4.5, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 0
	),

	# MULTIPLICATIVE MAJOR STATS (Expensive but reasonable since they compound)
	major_emperor = _create_upgrade(
		"Exuberant Emperor", "The Emperor's bonus multiplies by an additional 15% more.",
		8000.0, "major_stats.emperor", 1.15,  # 8x cost, smaller but still meaningful effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 505
	),
	major_empress = _create_upgrade(
		"Extended Empress", "The Empress backlog multiplies by an additional 20% more.",
		12000.0, "major_stats.empress", 1.2,  # 8x cost, smaller but still meaningful effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.3, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 504
	),
	major_hierophant = _create_upgrade(
		"Holy Hierophant", "The Hierophant charges multiply by an additional 18% more.",
		15000.0, "major_stats.hierophant", 1.18,  # 7.5x cost, smaller but meaningful effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 506
	),
	major_wheel_mult = _create_upgrade(
		"Wondrous Wheel", "Wheel multiplier effect is 22% stronger.",
		20000.0, "major_stats.wheel_multiplier", 1.22,  # 6.7x cost, smaller effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.4, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 511
	),
	major_moon = _create_upgrade(
		"Majestic Moon", "Moon multiplier effect is 25% stronger.",
		25000.0, "major_stats.moon", 1.25,  # 6.25x cost, smaller effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.5, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 519
	),
	major_tower = _create_upgrade(
		"Towering Tower", "Tower base power multiplies by an additional 20% more.",
		18000.0, "major_stats.tower", 1.2,  # 5x cost, smaller effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.3, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 517
	),
	major_justice = _create_upgrade(
		"Just Justice", "Justice settlement multiplier is 30% stronger.",
		10000.0, "major_stats.justice", 1.3,  # 8x cost, smaller effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 512
	),
	major_death = _create_upgrade(
		"Daunting Death", "Death multiplier effect is 22% stronger.",
		16000.0, "major_stats.death", 1.22,  # 6.4x cost, smaller effect
		UpgradeData.OperationType.MULTIPLY, DataStructures.GrowthType.EXPONENTIAL, 2.3, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 514
	),

	# MEDIUM POWER MAJOR STATS (Properly priced for exponential amplification)
	major_high_priestess = _create_upgrade(
		"Heightened High Priestess", "High Priestess has 1 extra charge.",
		25000.0, "major_stats.high_priestess", 1.0,  # 14x cost increase - charges get amplified exponentially
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 2.8, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 503
	),
	major_lovers = _create_upgrade(
		"Liberated Lovers", "Lovers affects 1 extra target.",
		30000.0, "major_stats.lovers", 1.0,  # 14x cost increase - extra targets = exponential benefit
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 2.9, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 507
	),
	major_wheel_charges = _create_upgrade(
		"Widespread Wheel", "Wheel has 1 extra charge.",
		35000.0, "major_stats.wheel_charges", 1.0,  # 14x cost increase - wheel charges compound
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 511
	),
	major_magician = _create_upgrade(
		"Mighty Magician", "Magician affects 1 extra target.",
		40000.0, "major_stats.magician", 1.0,  # 13x cost increase - extra targets compound with other effects
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 502
	),
	major_hanged_man = _create_upgrade(
		"Harmonious Hanged Man", "Hanged Man has 1 extra charge.",
		45000.0, "major_stats.hanged_man", 1.0,  # 14x cost increase - charges compound exponentially
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 513
	),
	major_strength = _create_upgrade(
		"Superior Strength", "Strength has 1 extra endurance.",
		50000.0, "major_stats.strength", 1.0,  # 14x cost increase - endurance affects multiple cards
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.2, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 509
	),
	major_star = _create_upgrade(
		"Sparkling Star", "Star is 1 power stronger.",
		60000.0, "major_stats.star", 1.0,  # 15x cost increase - star power gets multiplied by other majors
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.3, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 518
	),
	major_devil = _create_upgrade(
		"Devious Devil", "Devil has 1 extra charge.",
		65000.0, "major_stats.devil", 1.0,  # 14x cost increase - devil charges compound significantly
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.EXPONENTIAL, 3.4, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 516
	),

	# HIGH POWER BASE STATS (Additive but extremely expensive - they're already strong)
	major_temperance = _create_upgrade(
		"Titanous Temperance", "Temperance affects 25 extra cards.",
		100000.0, "major_stats.temperance", 25.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 4.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 515
	),
	major_sun_star = _create_upgrade(
		"Sun Supernova", "Sun adds 1 more Star per draw. Each Sun drawn generates an additional Star card.",
		250000.0, "major_stats.sun_star", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 4.5, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 520
	),
	major_judgement = _create_upgrade(
		"Judicious Judgement", "Judgement is 1 power stronger and amplifies all Major Arcana effects.",
		750000.0, "major_stats.judgement", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 5.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 521
	),
	major_sun_moon = _create_upgrade(
		"Symbiotic Sun", "Sun adds 1 more Moon per draw. Each Sun drawn generates an additional Moon card.",
		500000.0, "major_stats.sun_moon", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 4.8, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 520
	),

	# ULTIMATE POWER EXPONENTS (Additive but prohibitively expensive - small increases are game-changing)
	major_moon_exponent = _create_upgrade(
		"Mystical Moon Exponent", "Moon exponential power increases by 1.",
		10000000.0, "major_stats.moon_exponent", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 8.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 519
	),
	major_sun_exponent = _create_upgrade(
		"Solar Exponent Supremacy", "Sun exponential power increases by 1.",
		25000000.0, "major_stats.sun_exponent", 1.0,
		UpgradeData.OperationType.ADD, DataStructures.GrowthType.SUPERLINEAR, 10.0, -1, DataStructures.CurrencyType.CLAIRVOYANCE, 520
	)
}
#endregion

#region Pack Upgrades
var pack_upgrade_values: Dictionary = {
	pack_auto_draw = _upgrade_pack(
		"Auto Draw",
		"Allows you to draw cards automatically.",
		1.0,
		"pack_auto_draw",
		true,
		UpgradeData.OperationType.ADD,
		DataStructures.GrowthType.LINEAR,
		0,
		1
	),
	pack_auto_draw_speed = _upgrade_pack(
		"Auto Draw Speed",
		"Improves the speed of Auto Draw by 10%%.",
		1.0,
		"pack_auto_draw_speed",
		0.9,
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SUPERLINEAR,
		2,
		1
	),
	pack_card_value = _upgrade_pack(
		"Auto Draw Speed",
		"Improves the speed of Auto Draw by 10%%.",
		10.0,
		"pack_card_value",
		2,
		UpgradeData.OperationType.MULTIPLY,
		DataStructures.GrowthType.SLOW_EXPONENTIAL,
		0.95,
		1
	)
}
#endregion

#region Upgrade Creation
# returns a dictionary with format <UpgradeData.UpgradeType, <upgrade ID, >
# Create all upgrades directly for UpgradeManager compatibility
func create_all_upgrades() -> Dictionary:
	var all_upgrades: Dictionary = {}

	_create_upgrades_from_category(all_upgrades, general_upgrade_values, UpgradeData.UpgradeType.GENERAL)
	_create_upgrades_from_category(all_upgrades, cup_upgrade_values, UpgradeData.UpgradeType.CUPS)
	_create_upgrades_from_category(all_upgrades, wand_upgrade_values, UpgradeData.UpgradeType.WANDS)
	_create_upgrades_from_category(all_upgrades, pent_upgrade_values, UpgradeData.UpgradeType.PENTACLES)
	_create_upgrades_from_category(all_upgrades, sword_upgrade_values, UpgradeData.UpgradeType.SWORDS)
	_create_upgrades_from_category(all_upgrades, major_upgrade_values, UpgradeData.UpgradeType.MAJOR)
	_create_upgrades_from_category(all_upgrades, pack_upgrade_values, UpgradeData.UpgradeType.PACK)

	return all_upgrades

# Create upgrades from a specific category
func _create_upgrades_from_category(upgrades_dict: Dictionary, category_data: Dictionary, upgrade_type: UpgradeData.UpgradeType):
	for upgrade_id in category_data.keys():
		var data: Dictionary = category_data[upgrade_id]
		var upgrade_data = UpgradeData.new(
			upgrade_id,
			data["NAME"],
			data["DESCRIPTION"],
			data["START_COST"],
			data.get("MAX_UPGRADES", -1),
			data["STAT_PATH"],
			data["OPERATION_VALUE"],
			data.get("OPERATION", UpgradeData.OperationType.ADD),
			data["GROWTH"],
			data.get("GROWTH_MOD", 0),
			upgrade_type,
			data.get("ID", 0)
		)
		upgrades_dict[upgrade_id] = upgrade_data
#endregion