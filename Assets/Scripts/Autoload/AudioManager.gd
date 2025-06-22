extends Node
class_name audio_manager

@onready var card_flip: FmodEventEmitter2D = $CardFlip

func play_card_flip() -> void:
	card_flip.play_one_shot()