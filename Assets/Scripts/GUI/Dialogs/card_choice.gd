extends PanelContainer

var card_container_1: TextureRect
var card_container_2: TextureRect
var card_container_3: TextureRect

var containers: Array[TextureRect]
var current_choices: Array[Card] = []

func _ready():
	card_container_1= $HBoxContainer/Choice1
	card_container_2= $HBoxContainer/Choice2
	card_container_3= $HBoxContainer/Choice3
	containers = [
	card_container_1,
	card_container_2,
	card_container_3
	]
	_connect_signals()

func _connect_signals():
	for container in containers:
		# Debug: Check mouse filter settings
		DebugManager.print_ui_interactions("Card Choice: Container %s mouse_filter: %s" % [container.name, container.mouse_filter], DebugManager.DebugLevel.VERBOSE)
		
		container.mouse_entered.connect(_on_mouse_entered.bind(container))
		container.mouse_exited.connect(_on_mouse_exited.bind(container))
		container.gui_input.connect(_on_texture_clicked.bind(container))
	EventBus.card_choice_requested.connect(_on_card_choice_requested)

func _on_card_choice_requested(cards: Array[Card]) -> void:
	current_choices = cards
	show()
	_show_card_choices(cards)

func _show_card_choices(cards: Array[Card]) -> void:
	for i in cards.size():
		var card_texture = PreloadedResources.get_card_texture(cards[i])
		containers[i].texture = card_texture["background"]
		containers[i].get_child(0).texture = card_texture["overlay"]

func _on_mouse_entered(container: TextureRect) -> void:
	DebugManager.print_ui_interactions("Card Choice: Mouse entered container %s" % container.name, DebugManager.DebugLevel.VERBOSE)
	container.pivot_offset = container.size / 2
	container.scale = Vector2(1.1, 1.1)
	for other_container in containers:
		if container != other_container:
			other_container.pivot_offset = other_container.size / 2
			other_container.scale = Vector2(1.0, 1.0)

func _on_mouse_exited(container: TextureRect) -> void:
	DebugManager.print_ui_interactions("Card Choice: Mouse exited container %s" % container.name, DebugManager.DebugLevel.VERBOSE)
	container.scale = Vector2(1.0, 1.0)

func _on_texture_clicked(event: InputEvent, container: TextureRect) -> void:
	if Input.is_action_just_pressed("ui_click"):
		DebugManager.print_ui_interactions("Card Choice: Clicked on card choice", DebugManager.DebugLevel.VERBOSE)
		var index = containers.find(container)
		if index != -1:
			DebugManager.print_ui_interactions("Card Choice: Chose card index %d" % index, DebugManager.DebugLevel.VERBOSE)
			EventBus.emit_card_chosen(current_choices[index])
			current_choices = []
			hide()