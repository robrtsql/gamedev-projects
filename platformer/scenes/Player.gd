extends KinematicBody2D

var WALK_SPEED = 2
var velocity = Vector2()
var animator

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
	if (Input.is_action_pressed("ui_up")):
		velocity.y = -WALK_SPEED
	elif (Input.is_action_pressed("ui_down")):
		velocity.y =  WALK_SPEED
	else:
		velocity.y = 0
	
	if (velocity.x != 0 or velocity.y != 0):
		animator.set_anim("Walk")
		move(velocity)
	else:
		animator.set_anim("Idle")
	pass