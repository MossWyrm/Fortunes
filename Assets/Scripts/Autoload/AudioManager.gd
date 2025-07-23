extends Node
class_name AudioManager

#@onready var card_flip: FmodEventEmitter2D = $CardFlip

func _ready() -> void:
	print("Loaded into scene")
#	GM.audio_manager = self
	
func play_card_flip() -> void:
	pass
	#card_flip.play_one_shot()