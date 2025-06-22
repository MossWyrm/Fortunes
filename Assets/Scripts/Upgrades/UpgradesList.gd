extends Node
class_name UpgradesList

var general_upgrade_values: Dictionary = {
	gen_inversion_chance_mod = {
		"NAME" =  "Lucky",
		"DESCRIPTION" = "Increase the chance for a positive orientation by 0.5%",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["SUPERLINEAR"],
		"GROWTH_MOD" = 3,
		"STAT" = "gen_inversion_chance_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 0.5
	},
	gen_max_deck_size = {	
		"NAME" =  "Variety",
		"DESCRIPTION" = "Increase the maximum size of your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["SUPERLINEAR"],
		"GROWTH_MOD" = 3,
		"STAT" = "gen_max_deck_size",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	gen_min_deck_size = {	
		"NAME" =  "Precision",
		"DESCRIPTION" = "Increase the minimum cards required in your deck 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["SUPERLINEAR"],
		"GROWTH_MOD" = 3,
		"STAT" = "gen_min_deck_size",
		"OPERATION" = ID.Operation.SUBTRACT,
		"OPERATION_VALUE" = 1.0
	}

}

var cup_upgrade_values: Dictionary = {
	cup_basic_value = {
		"NAME" =  "Basic Value",
		"DESCRIPTION" = "Increase the value of numbered cup cards by 1.",
		"START_COST" = 10.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "cup_basic_value",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	cup_basic_quant = {
		"NAME" =  "Basic Quantity",
		"DESCRIPTION" = "Increase the amount of each numbered cup card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "cup_basic_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	cup_face_quant = {
		"NAME" =  "Faces Quantity",
		"DESCRIPTION" = "Increase the amount of each face cup card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "cup_face_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	cup_vessel_quant = {
		"NAME" =  "Add Vessel",
		"DESCRIPTION" = "Add another vessel to the Cups suit system, allowing for more clearvoiyance to be stored.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["EXPONENTIAL"],
		"GROWTH_MOD" = 2.0,
		"STAT" = "cup_vessel_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	cup_vessel_size = {
		"NAME" =  "Max Vessel Size",
		"DESCRIPTION" = "Increase the amount each vessel can hold by 50.",
		"START_COST" = 20.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "cup_vessel_size",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 50.0
	},
	cup_page_mod = {
		"NAME" =  "Page Upgrade",
		"DESCRIPTION" = "Increase / Decrease",
		"START_COST" = 10000.0,
		"GROWTH" = ID.GrowthType["EXPONENTIAL"],
		"GROWTH_MOD" = 2.0,
		"STAT" = "cup_page_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 0.05
	},
	cup_knight_mod = {
		"NAME" =  "Knight Upgrade",
		"DESCRIPTION" = "Increase / Decrease",
		"START_COST" = 10000.0,
		"GROWTH" = ID.GrowthType["EXPONENTIAL"],
		"GROWTH_MOD" = 2.0,
		"STAT" = "cup_knight_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	cup_queen_mod = {
		"NAME" =  "Queen Upgrade",
		"DESCRIPTION" = "Increase / Decrease",
		"START_COST" = 10000.0,
		"GROWTH" = ID.GrowthType["EXPONENTIAL"],
		"GROWTH_MOD" = 2.0,
		"STAT" = "cup_queen_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	}
}

var wand_upgrade_values: Dictionary ={
	wand_basic_value = {
		"NAME" =  "Basic Upgrade",
		"DESCRIPTION" = "Increase the amount of each numbered cup card you can add to your deck by 1.",
		"START_COST" = 10.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_basic_value",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_basic_quant = {
		"NAME" =  "Basic Quantity",
		"DESCRIPTION" = "Increase the amount of each numbered wand card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_basic_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_face_quant = {
		"NAME" =  "Faces Quantity",
		"DESCRIPTION" = "Increase the amount of each face wand card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_face_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_page_mod = {
		"NAME" =  "Page Upgrade",
		"DESCRIPTION" = "Increase the power of the Page by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_page_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_knight_mod = {
		"NAME" =  "Knight Upgrade",
		"DESCRIPTION" = "Increase the power of the Knight by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_knight_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_queen_mod = {
		"NAME" =  "Queen Upgrade",
		"DESCRIPTION" = "Increase the power of the Queen by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_queen_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	wand_king_mod = {
		"NAME" =  "King Upgrade",
		"DESCRIPTION" = "Increase the power of the King by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "wand_face_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	}
}

var pent_upgrade_values: Dictionary ={
	pent_basic_value = {
		"NAME" =  "Basic Upgrade",
		"DESCRIPTION" = "Increase the amount of each numbered Pentacles card you can add to your deck by 1.",
		"START_COST" = 10.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_basic_value",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	pent_basic_quant = {
		"NAME" =  "Basic Quantity",
		"DESCRIPTION" = "Increase the amount of each numbered Pentacles card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_basic_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	pent_face_quant = {
		"NAME" =  "Faces Quantity",
		"DESCRIPTION" = "Increase the amount of each face Pentacles card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_face_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	pent_page_mod = {
		"NAME" =  "Page Upgrade",
		"DESCRIPTION" = "Increase the power of the Page by 0.05.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_page_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 0.05
	},
	pent_knight_uses = {
		"NAME" =  "Knight Upgrade",
		"DESCRIPTION" = "Increase the amount of uses the Knight provides by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_knight_uses",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	pent_queen_uses = {
		"NAME" =  "Queen Upgrade",
		"DESCRIPTION" = "Increase the amount of times the Queen triggers by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_queen_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	pent_king_value = {
		"NAME" =  "King Value",
		"DESCRIPTION" = "Increase the value of the King's protection by 50.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_king_value",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 50.0
	},
	pent_king_uses = {
		"NAME" =  "King Uses",
		"DESCRIPTION" = "Increase the amount of charges the King provides by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "pent_king_uses",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	}
}
var sword_upgrade_values: Dictionary ={
	sword_basic_value = {
		"NAME" =  "Basic Upgrade",
		"DESCRIPTION" = "Increase the amount of each numbered Sword card you can add to your deck by 1.",
		"START_COST" = 10.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_basic_value",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	sword_basic_quant = {
		"NAME" =  "Basic Quantity",
		"DESCRIPTION" = "Increase the amount of each numbered Sword card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_basic_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	sword_face_quant = {
		"NAME" =  "Faces Quantity",
		"DESCRIPTION" = "Increase the amount of each face Sword card you can add to your deck by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_face_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	sword_knight_mod = {
		"NAME" =  "Knight Upgrade",
		"DESCRIPTION" = "Raises the minimum value of the Knights Add/Remove effect.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_knight_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	sword_knight_super = {
		"NAME" =  "Knight Transform",
		"DESCRIPTION" = "Once purchased, allows majors to be included in the pool.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_knight_super",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = true,
		"MAX_UPGRADES" = 1
	},
	sword_queen_mod = {
		"NAME" =  "Queen Upgrade",
		"DESCRIPTION" = "Increase the power of the Queen by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_queen_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	sword_king_mod = {
		"NAME" =  "King Value",
		"DESCRIPTION" = "Increase the cards the King works on by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "sword_king_mod",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	}
}
var major_upgrade_values: Dictionary ={
	major_quant = {
		"NAME" =  "Many Majors",
		"DESCRIPTION" = "Increase the amount of Major Arcana you can have in your deck by 1.",
		"START_COST" = 10000000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_quant",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_magician = {
		"NAME" =  "Mighty Magician",
		"DESCRIPTION" = "Increase the amount of cards The Magician affects by 1.",
		"START_COST" = 100000000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_magician",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_empress = {
		"NAME" =  "Extended Empress",
		"DESCRIPTION" = "Increase the backlog of cards The Empress uses by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_empress",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_emperor = {
		"NAME" =  "Exuberant Emperor",
		"DESCRIPTION" = "The Emperor increases the value of cards by 1 more.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_emperor",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_lovers = {
		"NAME" =  "Liberated Lovers",
		"DESCRIPTION" = "Increase the cards The Lovers targets by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_lovers",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_wheel_charges = {
		"NAME" =  "Widespread Wheel",
		"DESCRIPTION" = "Increase the cards a successful Wheel of Fortune affects by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_wheel_charges",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_wheel_mult = {
		"NAME" =  "Wondrous Wheel",
		"DESCRIPTION" = "Increase the multiplier of a successful Wheel of Fortune by 0.5.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_wheel_mult",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 0.5
	},
	major_temperance = {
		"NAME" =  "Titanous Temperance",
		"DESCRIPTION" = "Increase the target line of Temperance by 50.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_temperance",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 50.0
	},
	major_star = {
		"NAME" =  "Sparkling Star",
		"DESCRIPTION" = "Increase the value of The Star by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_star",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_moon = {
		"NAME" =  "Majestic Moon",
		"DESCRIPTION" = "Increase the multiplier of The Moon by 1.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_moon",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	},
	major_sun_star = {
		"NAME" =  "Sun Supernova",
		"DESCRIPTION" = "The Sun adds 2 more Stars to your deck on draw.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_sun_star",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 2.0
	},
	major_sun_moon = {
		"NAME" =  "Symbiotic Sun",
		"DESCRIPTION" = "The Sun adds 1 more Moon to your deck on draw.",
		"START_COST" = 1000.0,
		"GROWTH" = ID.GrowthType["LINEAR"],
		"GROWTH_MOD" = 0,
		"STAT" = "major_sun_moon",
		"OPERATION" = ID.Operation.ADD,
		"OPERATION_VALUE" = 1.0
	}
}

func get_initial_list() -> Dictionary:
	var initial_list: Dictionary = {
		ID.UpgradeType.GENERAL: _create_upgrade_list(general_upgrade_values),
		ID.UpgradeType.CUPS : _create_upgrade_list(cup_upgrade_values),
		ID.UpgradeType.WANDS: _create_upgrade_list(wand_upgrade_values),
		ID.UpgradeType.PENTACLES: _create_upgrade_list(pent_upgrade_values),
		ID.UpgradeType.SWORDS: _create_upgrade_list(sword_upgrade_values),
		ID.UpgradeType.MAJOR: _create_upgrade_list(major_upgrade_values)
	}
	return initial_list
	
func _create_upgrade_list(dict: Dictionary) -> Dictionary:
	var upgrades: Dictionary = {}
	for key in dict.keys():
		var values: Dictionary = dict[key]
		var max_upgrades = values["MAX_UPGRADES"] if values.keys().has("MAX_UPGRADES") else -1
		var id = values["ID"] if values.keys().has("ID") else 0
		var upgrade: Upgrade = Upgrade.new(
				values["NAME"], 
				values["DESCRIPTION"],
				id,
				values["START_COST"],
				values["GROWTH"],
				values["GROWTH_MOD"],
				values["STAT"],
				values["OPERATION"],
				values["OPERATION_VALUE"],
				max_upgrades
				)
		upgrades[key] = upgrade
	return upgrades