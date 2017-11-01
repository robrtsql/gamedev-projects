# Player controller script.

extends KinematicBody2D
var Interpolate = load("Interpolate.gd")

var state = 1
var GROUNDED = 0
var MIDAIR = 1

var facing = 1
var LEFT = 0
var RIGHT = 1

var WALK_SPEED = 125
var TERMINAL_VELOCITY = 200
var UP_ANGLE = (PI/-2.0)
var MAX_UP_ANGLE = UP_ANGLE + (PI/4)
var MIN_UP_ANGLE = UP_ANGLE - (PI/4)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 25.0
var velocity = Vector2()
var animator
var grounded = false
var jump_held
var interpolater
var sprite

func _ready():
	animator = get_node("Sprite/AnimationPlayer")
	set_fixed_process(true)
	set_process(true)
	
	sprite = get_node("Sprite")
	interpolater = Interpolate.new()
	interpolater.initialize(sprite)

func _move_horizontally():
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
		facing = LEFT
	elif (Input.is_action_pressed("ui_right")):
		velocity.x =  WALK_SPEED
		facing = RIGHT
	else:
		velocity.x = 0

func _apply_gravity(delta):
	velocity.y += 300 * delta
	if (velocity.y > TERMINAL_VELOCITY):
		velocity.y = TERMINAL_VELOCITY

func _handle_jump(delta):
	if (Input.is_action_pressed("ui_up")):
		velocity.y = -200

func _move_with(velocity, delta):
	if (velocity.x == 0 and velocity.y == 0):
		return
	move_and_slide(velocity, FLOOR_NORMAL)
	if is_move_and_slide_on_floor():
		grounded = true
	else:
		print(velocity)
		grounded = false
	if (grounded):
		state = GROUNDED
	else:
		state = MIDAIR

func _fixed_process(delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	var prev_position = get_pos()
	var teleported = false
	
	if (state == GROUNDED):
		_move_horizontally()
		_handle_jump(delta)
		_apply_gravity(delta)
		if (velocity.x != 0):
			animator.upsert("Walk")
		else:
			animator.upsert("Idle")
		if facing == LEFT:
			sprite.set_flip_h(false)
		elif facing == RIGHT:
			sprite.set_flip_h(true)
		_move_with(velocity, delta)
	elif (state == MIDAIR):
		_move_horizontally()
		_apply_gravity(delta)
		animator.upsert("Fall")
		if facing == LEFT:
			sprite.set_flip_h(false)
		elif facing == RIGHT:
			sprite.set_flip_h(true)
		_move_with(velocity, delta)
	interpolater.fixed_helper(delta, prev_position, teleported)
	#var latest_pos = get_pos()
	#set_pos(Vector2(round(latest_pos.x), round(latest_pos.y)))

func _process(delta):
	interpolater.idle_interpolate(delta, get_pos())