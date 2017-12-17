# Player controller script.

extends KinematicBody2D
var Interpolate = load("Interpolate.gd")

var GROUNDED = 0
var MIDAIR = 1
var state = 1

var LEFT = 0
var RIGHT = 1
var facing = RIGHT

var INITIAL_JUMP_SPEED = -285
var GRAVITY_ACCEL = 15
var WALK_SPEED = 82.5
var TERMINAL_VELOCITY = 420
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
	if not grounded:
		velocity.y += GRAVITY_ACCEL
		if (velocity.y > TERMINAL_VELOCITY):
			velocity.y = TERMINAL_VELOCITY
	else:
		velocity.y = 50

func _handle_jump(delta):
	if (Input.is_action_pressed("ui_up")):
		velocity.y = INITIAL_JUMP_SPEED
		state = MIDAIR

func _handle_jump_cutoff(delta):
	if (not Input.is_action_pressed("ui_up")
	    and velocity.y < 0):
		velocity.y = 0

func _move_with(velocity, delta):
	if (velocity.x == 0 and velocity.y == 0):
		return
	move_and_slide(velocity, FLOOR_NORMAL)
	if is_move_and_slide_on_floor():
		grounded = true
	else:
		grounded = false
	if (grounded):
		state = GROUNDED
	else:
		state = MIDAIR

func _flip_to_facing():
	if facing == LEFT:
		sprite.set_flip_h(false)
	elif facing == RIGHT:
		sprite.set_flip_h(true)

func _fixed_process(delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	var prev_position = get_pos()
	var teleported = false
	
	if (state == GROUNDED):
		_move_horizontally()
		_apply_gravity(delta)
		_handle_jump(delta)
		if (velocity.x != 0):
			animator.upsert("Walk")
		else:
			animator.upsert("Idle")
		_flip_to_facing()
		_move_with(velocity, delta)
	elif (state == MIDAIR):
		_move_horizontally()
		_apply_gravity(delta)
		_handle_jump_cutoff(delta)
		animator.upsert("Fall")
		_flip_to_facing()
		_move_with(velocity, delta)
	interpolater.fixed_helper(delta, prev_position, teleported)

func _process(delta):
	interpolater.idle_interpolate(delta, get_pos())