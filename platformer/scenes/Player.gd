extends KinematicBody2D

var WALK_SPEED = 100
var TERMINAL_VELOCITY = 200
var UP_ANGLE = (PI/-2.0)
var MAX_UP_ANGLE = UP_ANGLE + (PI/4)
var MIN_UP_ANGLE = UP_ANGLE - (PI/4)
var velocity = Vector2()
var animator
var grounded = false

func _ready():
	animator = get_node("Sprite/AnimationPlayer")
	set_fixed_process(true)

func _fixed_process(delta):
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
	elif (Input.is_action_pressed("ui_right")):
		velocity.x =  WALK_SPEED
	else:
		velocity.x = 0
	if (not grounded):
		velocity.y += 300 * delta
	if (velocity.y > TERMINAL_VELOCITY):
		velocity.y = TERMINAL_VELOCITY
	
	if (velocity.x != 0 or velocity.y != 0):
		animator.set_anim("Walk")
		var motion = velocity * delta
		move(motion)
		
		grounded = false
		if (is_colliding()):
			var n = get_collision_normal()
			var normal_angle = atan(n.y / n.x)
			if (normal_angle >= MIN_UP_ANGLE 
				and normal_angle <= MAX_UP_ANGLE):
				velocity.y = 0
				grounded = true
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	else:
		animator.set_anim("Idle")
	pass