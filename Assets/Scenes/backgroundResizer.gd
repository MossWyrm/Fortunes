extends AnimatedSprite2D

var _parent: Node

var sprite_texture : Texture

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_animation : String = animation
	sprite_texture = sprite_frames.get_frame_texture(current_animation, 0)

	
	_parent = get_parent()
	change_size()
	get_viewport().size_changed.connect(change_size)


func change_size():
	var _parentAspect = _parent.size.x / _parent.size.y
	var _intendedAspect = sprite_texture.get_size().x / sprite_texture.get_size().y

	var scaleRef : Vector2
	if _parentAspect > _intendedAspect:
		var scaling = _parent.size.x / sprite_texture.get_size().x
		scaleRef.x = scaling
		scaleRef.y = scaling
	else:
		var scaling = _parent.size.y / sprite_texture.get_size().y
		scaleRef.x = scaling
		scaleRef.y = scaling
	scale = scaleRef
