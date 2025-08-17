extends Control
class_name CardSelectDisplayBoxLocked
## Locked card display box for deck creator
##
## Shows cards that are locked and need to be unlocked with clairvoyance currency.
## Displays unlock cost, availability status, and provides visual feedback.

#region Node References
@onready var card_face: TextureRect = $CardFace
@onready var card_overlay: TextureRect = $CardFace/CardOverlay
@onready var unlock_button: Button = $UnlockButton
@onready var title: Label = $UnlockButton/MarginContainer/VBoxContainer/CardTitle
@onready var cost: Label = $UnlockButton/MarginContainer/VBoxContainer/CardCost
@onready var slider: ColorRect = $UnlockButton/MASK/Bar
@onready var slider_mask: Panel = $UnlockButton/MASK
#endregion

#region Display Management
# Display locked card information and unlock status
func display(card: Card) -> void:
	if not card:
		push_error("CardSelectDisplayBoxLocked: Cannot display null card")
		return
	
	_setup_card_visuals(card)
	_setup_unlock_information(card)
	_update_unlock_availability(card)

# Setup card visual elements
func _setup_card_visuals(card: Card) -> void:
	var texture = PreloadedResources.get_card_texture(card)
	
	if card_face:
		card_face.texture = texture["background"]
	
	if card_overlay:
		card_overlay.texture = texture["overlay"]

# Setup unlock cost and title information
func _setup_unlock_information(card: Card) -> void:
	if title:
		title.text = card.card_title
	
	if cost:
		var cost_text = _get_unlock_cost_text(card)
		cost.text = cost_text

# Update unlock button availability based on player resources
func _update_unlock_availability(card: Card) -> void:
	if not unlock_button:
		return
	
	var can_unlock = _can_unlock_card(card)
	unlock_button.disabled = not can_unlock

# Get formatted unlock cost text
func _get_unlock_cost_text(card: Card) -> String:
	if card.blocked:
		return "Unavailable"
	else:
		return "Unlock: " + Tools.get_shorthand(card.unlock_cost)

# Check if player can unlock this card
func _can_unlock_card(card: Card) -> bool:
	if card.blocked:
		return false
	
	if ValidationUtils.has_stats():
		return GameManager.game_state.stats.clairvoyance >= card.unlock_cost
	
	return false
#endregion

#region Progress Display
# Set unlock progress slider percentage
func set_slider_percent(percent: float) -> void:
	if slider:
		slider.scale.x = clamp(percent, 0.0, 1.0)
#endregion

	