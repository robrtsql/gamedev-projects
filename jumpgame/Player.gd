extends KinematicBody2D
var Interpolate = load("Interpolate.gd")

var state = 1
var GROUNDED = 0
var MIDAIR = 1

var WALK_SPEED = 125
var TERMINAL_VELOCITY = 200
var UP_ANGLE = (PI/-2.0)
var MAX_UP_ANGLE = UP_ANGLE + (PI/4)
var MIN_UP_ANGLE = UP_ANGLE - (PI/4)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 25.0
var velocity = Vector2()
var animator
var sprite
var grounded = false
var jump_held
var interpolater

func _ready():
	animator = get_node("Sprite/AnimationPlayer")
	set_physics_process(true)
	set_process(true)
	
	sprite = get_node("Sprite")

	interpolater = Interpolate.new()
	interpolater.initialize(sprite)

func _move_horizontally():
	if (Input.is_action_pressed("ui_left")):
		velocity.x = -WALK_SPEED
		sprite.flip_h = false
	elif (Input.is_action_pressed("ui_right")):
		velocity.x =  WALK_SPEED
		sprite.flip_h = true
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
	move_and_slide(velocity, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	grounded = is_on_floor()
	if (grounded):
		state = GROUNDED
	else:
		state = MIDAIR

func _physics_process(delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	var prev_position = get_position()
	var teleported = false
	
	if (state == GROUNDED):
		_move_horizontally()
		_handle_jump(delta)
		_apply_gravity(delta)
		if (velocity.x != 0):
			animator.upsert("Walk")
		else:
			animator.upsert("Idle")
		_move_with(velocity, delta)
	elif (state == MIDAIR):
		_move_horizontally()
		_apply_gravity(delta)
		animator.upsert("Fall")
		_move_with(velocity, delta)
	interpolater.fixed_helper(delta, prev_position, teleported)

func _process(delta):
	interpolater.idle_interpolate(delta, get_position())
