class_name UpgradeDisplayData
extends RefCounted
## Complete display data for upgrade buttons - everything needed for display

# All data needed for display (no manager calls required)
var upgrade_id: String			# Provides the ID from UpgradeList
var display_title: String        # "Upgrade Name [2/5]" or "Upgrade Name"
var description: String			# Description of the Upgrade's Functionality
var cost_text: String           # "Cost: 1.2K" or "~ Fully Upgraded ~"
var cost_color: Color           # Pre-calculated color
var currency_icon: Texture2D    # Pre-loaded texture
var card_background: Texture2D  # Pre-loaded texture
var card_overlay: Texture2D     # Pre-loaded texture (can be null)
var card_id: int               # Card ID for tooltip display (0 if no associated card)
var is_purchaseable: bool       # Can player buy this right now?
var is_maxed: bool             # Is at max level?

## Creates display data from upgrade and manager state
static func create(upgrade: UpgradeData, manager: UpgradeManager) -> UpgradeDisplayData:
	var data = UpgradeDisplayData.new()
	
	# Basic info
	data.upgrade_id = upgrade.id
	data.description = upgrade.description
	data.card_id = upgrade.card_id
	
	# Calculate current state
	var purchase_count = manager.get_purchase_count(upgrade.id)
	var current_cost = manager.get_upgrade_cost(upgrade.id)
	var is_affordable = manager.can_purchase_upgrade(upgrade.id)
	var maxed = manager.is_max_level(upgrade.id)
	
	# Format title with purchase count
	if upgrade.max_purchases > 0:
		data.display_title = "%s [%d/%d]" % [upgrade.name, purchase_count, upgrade.max_purchases]
	elif purchase_count > 0:
		data.display_title = "%s [%d]" % [upgrade.name, purchase_count]
	else:
		data.display_title = upgrade.name
	
	# Format cost and color
	if maxed:
		data.cost_text = "~ Fully Upgraded ~"
		data.cost_color = Color.GRAY
	else:
		data.cost_text = "Cost: " + Tools.get_shorthand(int(current_cost))
		data.cost_color = DataStructures.core_color.GOOD if is_affordable else DataStructures.core_color.BAD
	
	# Load textures
	data.currency_icon = PreloadedResources.currency_type[upgrade.currency_type]
	data.card_background = PreloadedResources.get_upgrade_background(upgrade.type if upgrade.type != UpgradeData.UpgradeType.PACK else UpgradeData.UpgradeType.GENERAL)
	
	if upgrade.card_id > 0:
		var textures = PreloadedResources.get_card_texture(GameManager.game_state.deck_manager.get_card(upgrade.card_id))
		data.card_overlay = textures.get("overlay")
	
	# Set states
	data.is_purchaseable = is_affordable and not maxed
	data.is_maxed = maxed
	
	return data

## Batch create for multiple upgrades
static func create_batch(upgrades: Dictionary, manager: UpgradeManager) -> Array[UpgradeDisplayData]:
	var data_array: Array[UpgradeDisplayData] = []
	for upgrade in upgrades.values():
		data_array.append(create(upgrade, manager))
	return data_array
