extends Sprite

func _ready():
	_center()
	pass

func _center():
	var viewport_size = get_viewport().get_rect().size
	var texture_width = get_texture().get_width()
	var scaling_factor = viewport_size.x / texture_width
	set_scale(Vector2(scaling_factor, scaling_factor))
	set_pos(viewport_size / 2)