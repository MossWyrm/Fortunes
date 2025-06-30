extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.pack_complete.connect(pack_complete)

func pack_complete() -> void:
	Events.emit_update_currency(1,ID.CurrencyType.PACK)