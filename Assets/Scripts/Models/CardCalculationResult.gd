class_name CardCalculationResult
extends RefCounted

# Represents the result of a card calculation
var base_value: int
var modified_value: int
var final_value: int
var clairvoyance_change: int
var effects_applied: Array[String]

func _init():
    base_value = 0
    modified_value = 0
    final_value = 0
    clairvoyance_change = 0
    effects_applied = []