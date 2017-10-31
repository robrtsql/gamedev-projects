extends KinematicBody2D
var Interpolate = load("Interpolate.gd")

var interpolater

func _ready():
	set_process(true)
	set_fixed_process(true)
	interpolater = Interpolate.new()
	interpolater.initialize(get_node("Sprite"))

func _fixed_process(delta):
	var prev_position = get_pos()
	set_pos(get_pos() + Vector2(100*delta, 0))
	if (get_pos().x > 512):
		translate(Vector2(-1024, 0))
	interpolater.fixed_helper(delta, prev_position, false)

func _process(delta):
	interpolater.idle_interpolate(delta, get_pos())