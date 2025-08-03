extends Node

# New GameManager autoload that initializes the new architecture
# This replaces the old GM singleton and provides backward compatibility

var game_state: RefCounted
var migration_layer: RefCounted

func _ready():
	# Initialize the new architecture
	_initialize_new_architecture()
	
	# Set up migration layer
	_setup_migration_layer()
	
	# Connect to existing autoloads for backward compatibility
	_connect_legacy_systems()

func _initialize_new_architecture():
	# For now, we'll initialize the new architecture when the classes are properly loaded
	# This will be implemented in Phase 4 when we have all the new systems ready
	pass

func _setup_migration_layer():
	# Set up the migration layer when ready
	pass

func _connect_legacy_systems():
	# Connect to existing autoloads to maintain backward compatibility
	var stats = get_node("/root/Stats")
	if stats:
		# Connect stats updates to new system
		stats.connect("stats_updated", Callable(self, "_on_legacy_stats_updated"))
	
	var deck = get_node("/root/Deck")
	if deck:
		# Connect deck updates to new system
		deck.connect("deck_updated", Callable(self, "_on_legacy_deck_updated"))

func _on_legacy_stats_updated():
	# Sync legacy stats with new system
	if game_state and game_state.game_stats:
		_sync_legacy_stats()

func _on_legacy_deck_updated():
	# Sync legacy deck with new system
	if game_state and game_state.deck_manager:
		_sync_legacy_deck()

func _sync_legacy_stats():
	var stats = get_node("/root/Stats")
	if not stats or not game_state.game_stats:
		return
	
	# Sync general stats
	game_state.game_stats.total_cards_drawn = stats.total_cards_drawn
	game_state.game_stats.total_money_earned = stats.total_money_earned
	game_state.game_stats.prestige_count = stats.prestige_count
	game_state.game_stats.pause_drawing = stats.pause_drawing
	
	# Sync suit-specific stats
	game_state.game_stats.cup_stats.cards_drawn = stats.cups_drawn
	game_state.game_stats.cup_stats.total_value = stats.cups_total
	game_state.game_stats.cup_stats.multiplier = stats.cups_multiplier
	game_state.game_stats.cup_stats.bonus_cards = stats.cups_bonus_cards
	
	game_state.game_stats.wand_stats.cards_drawn = stats.wands_drawn
	game_state.game_stats.wand_stats.total_value = stats.wands_total
	game_state.game_stats.wand_stats.multiplier = stats.wands_multiplier
	game_state.game_stats.wand_stats.bonus_cards = stats.wands_bonus_cards
	
	game_state.game_stats.pentacle_stats.cards_drawn = stats.pentacles_drawn
	game_state.game_stats.pentacle_stats.total_value = stats.pentacles_total
	game_state.game_stats.pentacle_stats.multiplier = stats.pentacles_multiplier
	game_state.game_stats.pentacle_stats.bonus_cards = stats.pentacles_bonus_cards
	
	game_state.game_stats.sword_stats.cards_drawn = stats.swords_drawn
	game_state.game_stats.sword_stats.total_value = stats.swords_total
	game_state.game_stats.sword_stats.multiplier = stats.swords_multiplier
	game_state.game_stats.sword_stats.bonus_cards = stats.swords_bonus_cards
	
	game_state.game_stats.major_stats.cards_drawn = stats.majors_drawn
	game_state.game_stats.major_stats.total_value = stats.majors_total
	game_state.game_stats.major_stats.multiplier = stats.majors_multiplier
	game_state.game_stats.major_stats.bonus_cards = stats.majors_bonus_cards
	
	# Sync major arcana specific stats
	game_state.game_stats.major_stats.high_priestess = stats.major_high_priestess
	game_state.game_stats.major_stats.hierophant = stats.major_hierophant
	game_state.game_stats.major_stats.strength = stats.major_strength
	game_state.game_stats.major_stats.justice = stats.major_justice
	game_state.game_stats.major_stats.hanged_man = stats.major_hanged_man
	game_state.game_stats.major_stats.death = stats.major_death

func _sync_legacy_deck():
	var deck = get_node("/root/Deck")
	if not deck or not game_state.deck_manager:
		return
	
	# Convert legacy deck format to new format
	var new_deck: Array = []
	for card_data in deck.deck:
		# For now, we'll use the legacy card format until the new Card class is properly loaded
		new_deck.append(card_data)
	
	# Update the new deck manager
	game_state.deck_manager.set_deck(new_deck)

# Backward compatibility methods
func get_deck() -> Array:
	if game_state and game_state.deck_manager:
		return game_state.deck_manager.get_deck()
	return []

func draw_card() -> RefCounted:
	if game_state and game_state.deck_manager:
		return game_state.deck_manager.draw_card()
	return null

func peek_card() -> RefCounted:
	if game_state and game_state.deck_manager:
		return game_state.deck_manager.peek_card()
	return null

func get_stats() -> RefCounted:
	if game_state:
		return game_state.game_stats
	return null

func emit_card_drawn(card: RefCounted):
	if game_state and game_state.event_bus:
		game_state.event_bus.emit_card_drawn(card)

func emit_currency_updated(currency_type: int, amount: int):
	if game_state and game_state.event_bus:
		game_state.event_bus.emit_currency_updated(currency_type, amount) 