extends Node
class_name Upgrade

@export var title: String
@export var description: String
@export var times_purchased: int
@export var initial_cost: float

func _scaling_formula():
	print("Scaling formula not implemented on "+ name)
	return 0


func _cost():
	return _scaling_formula()


