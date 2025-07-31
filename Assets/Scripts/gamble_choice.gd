extends Control

@onready var skip: Button = $MarginContainer/HBoxContainer/Skip
@onready var button_10: Button = $"MarginContainer/HBoxContainer/10"
@onready var button_25: Button = $"MarginContainer/HBoxContainer/25"
@onready var button_50: Button = $"MarginContainer/HBoxContainer/50"
@onready var button_100: Button = $"MarginContainer/HBoxContainer/100"

func _ready() -> void:
    Events.hanged_man_choice.connect(show)
    skip.pressed.connect(_choose_value.bind(0.0))
    button_10.pressed.connect(_choose_value.bind(0.1))
    button_25.pressed.connect(_choose_value.bind(0.25))
    button_50.pressed.connect(_choose_value.bind(0.5))
    button_100.pressed.connect(_choose_value.bind(1.0))


func _choose_value(val: float) -> void:
    Events.emit_hanged_man_chosen(val)
    hide()