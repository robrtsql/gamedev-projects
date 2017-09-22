extends KinematicBody2D
var Interpolate = load("Interpolate.gd")

var WALK_SPEED = 100
var velocity = Vector2()
var interpolater

func _ready():
	set_fixed_process(true)
	set_process(true)
	OS.set_target_fps(60)
	
	interpolater = Interpolate.new()
	interpolater.initialize(get_node("Sprite"))

func _set_velocity_based_on_input():
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

func _move_with(velocity, delta):
	if (velocity.x == 0 and velocity.y == 0):
		return
	var motion = velocity * delta
	move(motion)

func _determine_if_changed_direction(old_velocity, velocity):
	var changed_x = _determine_if_comp_changed_dir(old_velocity.x, velocity.x)
	var changed_y = _determine_if_comp_changed_dir(old_velocity.y, velocity.y)
	var changed_direction = changed_x or changed_y
	if changed_direction:
		print('changed direction!')
	return changed_direction

func _determine_if_comp_changed_dir(old_comp, comp):
	"""Determine if this one component changed direction"""
	var old_comp_sign = _get_sign(old_comp)
	var comp_sign = _get_sign(comp)
	return old_comp_sign != comp_sign

func _get_sign(number):
	if (number == 0):
		return 0
	else:
		return 1 if number > 0 else -1

func _fixed_process(delta):
	if (Input.is_key_pressed(KEY_ESCAPE)):
		get_tree().quit()
	var prev_position = get_pos()
	
	var old_velocity = velocity
	_set_velocity_based_on_input()
	#var teleported = _determine_if_changed_direction(old_velocity, velocity)
	var teleported = false
	_move_with(velocity, delta)
	interpolater.fixed_helper(delta, prev_position, teleported)
	#var latest_pos = get_pos()
	#set_pos(Vector2(round(latest_pos.x), round(latest_pos.y)))

func _process(delta):
	interpolater.idle_interpolate(delta, get_pos())