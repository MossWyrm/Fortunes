extends Control
class_name TutorialNode

## Tutorial interface controller
## Manages tutorial page navigation with previous/next buttons.
## Handles page transitions and button state management.

@onready var next_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Next
@onready var next_overlay: ColorRect = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Next/MarginContainer/TextureRect/Overlay
@onready var prev_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Prev
@onready var prev_overlay: ColorRect = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Prev/MarginContainer/TextureRect/Overlay
@onready var close_button: Button = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/Close

@export var tutorial_pages: Array[Node] = []

var current_index: int = 0

#region Initialization
func _ready() -> void:
	_connect_signals()
	_initialize_tutorial()

func _connect_signals() -> void:
	close_button.pressed.connect(_on_close_pressed)
	prev_button.pressed.connect(_on_previous_pressed)
	next_button.pressed.connect(_on_next_pressed)

func _initialize_tutorial() -> void:
	_update_button_states()
#endregion

#region Event Handlers
func _on_previous_pressed() -> void:
	if _can_go_previous():
		_hide_current_page()
		current_index -= 1
		_show_current_page()
		_update_button_states()

func _on_next_pressed() -> void:
	if _can_go_next():
		_hide_current_page()
		current_index += 1
		_show_current_page()
		_update_button_states()

func _on_close_pressed() -> void:
	hide()
#endregion

#region Page Management
func _hide_current_page() -> void:
	if _is_valid_page_index(current_index):
		tutorial_pages[current_index].hide()

func _show_current_page() -> void:
	if _is_valid_page_index(current_index):
		tutorial_pages[current_index].show()

func _is_valid_page_index(index: int) -> bool:
	return index >= 0 and index < tutorial_pages.size()
#endregion

#region Button State Management
func _update_button_states() -> void:
	_update_previous_button()
	_update_next_button()

func _update_previous_button() -> void:
	if prev_button and prev_overlay:
		var can_go_prev = _can_go_previous()
		prev_button.disabled = not can_go_prev
		prev_overlay.visible = not can_go_prev

func _update_next_button() -> void:
	if next_button and next_overlay:
		var can_go_next = _can_go_next()
		next_button.disabled = not can_go_next
		next_overlay.visible = not can_go_next

func _can_go_previous() -> bool:
	return current_index > 0

func _can_go_next() -> bool:
	return current_index < tutorial_pages.size() - 1
#endregion