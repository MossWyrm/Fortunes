extends PopupMenu

## Debug menu for testing features
## Accessed via simultaneous "M" and "W" key presses

func _ready():
	_create_money_menu()
	_create_draw_card_menu()
	_create_reset_menu()
	_create_shuffle_menu()
	
func _create_money_menu():
	add_submenu_item("Currency", "MoneyMenu")
	var money_menu = $MoneyMenu
	money_menu.add_submenu_item("Clairvoyance", "Clairvoyance")
	money_menu.add_submenu_item("Packs", "Packs")
	var clairvoyance_menu = $MoneyMenu/Clairvoyance
	clairvoyance_menu.add_item("Clear", 0)
	clairvoyance_menu.add_item("+ 1000", 1000)
	clairvoyance_menu.add_item("+ 1M", 1000000)
	clairvoyance_menu.add_item("+ 1B", 1000000000)
	clairvoyance_menu.add_item("+ 1T", 1000000000000)
	clairvoyance_menu.id_pressed.connect(_add_currency.bind(DataStructures.CurrencyType.CLAIRVOYANCE))
	var packs_menu = $MoneyMenu/Packs
	packs_menu.add_item("Clear", 0)
	packs_menu.add_item("+ 1", 1)
	packs_menu.add_item("+ 10", 10)
	packs_menu.add_item("+ 100", 100)
	packs_menu.add_item("+ 1000", 1000)
	packs_menu.id_pressed.connect(_add_currency.bind(DataStructures.CurrencyType.PACK))

func _create_draw_card_menu():
	add_submenu_item("Draw Card", "CardMenu")
	var card_menu = $CardMenu
	card_menu.add_submenu_item("Cups", "Cups")
	card_menu.add_submenu_item("Wands", "Wands")
	card_menu.add_submenu_item("Pentacles", "Pentacles")
	card_menu.add_submenu_item("Swords", "Swords")
	card_menu.add_submenu_item("Majors", "Majors")
	_add_cards_to_menu($CardMenu/Cups, DataStructures.SuitType.CUPS)
	_add_cards_to_menu($CardMenu/Wands, DataStructures.SuitType.WANDS)
	_add_cards_to_menu($CardMenu/Pentacles, DataStructures.SuitType.PENTACLES)
	_add_cards_to_menu($CardMenu/Swords, DataStructures.SuitType.SWORDS)
	_add_cards_to_menu($CardMenu/Majors, DataStructures.SuitType.MAJOR)

func _create_reset_menu():
	add_submenu_item("Reset", "ResetMenu")
	var reset_menu = $ResetMenu
	reset_menu.add_item("~ Full Reset ~", DataStructures.GameLayer.ALL)
	reset_menu.add_item("Deck", DataStructures.GameLayer.DECK)
	reset_menu.add_item("Packs", DataStructures.GameLayer.PACK)
	reset_menu.id_pressed.connect(_reset_game)

func _create_shuffle_menu():
	add_submenu_item("Shuffle", "Shuffle")
	var shuffle_menu = $Shuffle
	shuffle_menu.add_item("Shuffle Safely", 0)
	shuffle_menu.add_item("Shuffle Unsafely", 1)
	shuffle_menu.id_pressed.connect(func(id):
		var safely = id == 0
		EventBus.emit_request_shuffle(safely)
	)

func _add_currency(amount, currency_type: DataStructures.CurrencyType):
	match currency_type:
		DataStructures.CurrencyType.CLAIRVOYANCE:
			if amount == 0:
				EventBus.emit_currency_updated(-GameManager.game_state.stats.clairvoyance, DataStructures.CurrencyType.CLAIRVOYANCE)
			else:
				EventBus.emit_currency_updated(amount, DataStructures.CurrencyType.CLAIRVOYANCE)
		DataStructures.CurrencyType.PACK:
			if amount == 0:
				EventBus.emit_currency_updated(-GameManager.game_state.stats.packs, DataStructures.CurrencyType.PACK)
			else:
				EventBus.emit_currency_updated(amount, DataStructures.CurrencyType.PACK)
		_:
			DebugManager.print_system_general("Unknown currency type: " + str(currency_type), DebugManager.DebugLevel.WARNING)

func _add_cards_to_menu(card_menu: PopupMenu, suit_type: DataStructures.SuitType):
	var cards = GameManager.game_state.deck_manager.get_all_cards()
	for card in cards:
		if card.suit == suit_type:
			card_menu.add_item(CardDescriptionFactory.get_card_description(card,false)["title"], card.id)
	card_menu.id_pressed.connect(_force_card_draw)

func _force_card_draw(card_id: int):
	GameManager.game_state.deck_manager.force_draw_card(card_id)

func _reset_game(reset_type: DataStructures.GameLayer) -> void:
	GameManager.game_state.reset_game(reset_type)