extends Node

@export var upgrade: BaseUpgrade

func _cost():
	return upgrade._cost()
