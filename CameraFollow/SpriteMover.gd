extends Sprite

export(bool) var physics = false

func _ready():
	set_process(true)
	set_physics_process(true)
	pass

func _process(delta):
	if not physics:
		translate(Vector2(randi()%1000+1, 0))

func _physics_process(delta):
	if physics:
		translate(Vector2(randi()%1000+1, 0))