const idle_accum = 0
const sixty_fps_frame = 1.0 / 60.0
var drawable_node = null

var teleported = false
var prev_position = null

func initialize(given_drawable_node):
	drawable_node = given_drawable_node

func idle_interpolate(delta, current_position):
	"""Should be called once during _process--needed in order to interpolate"""
	var new_idle_accum = idle_accum + delta
	while(new_idle_accum > sixty_fps_frame):
		new_idle_accum = new_idle_accum - sixty_fps_frame
	var diff = idle_accum - new_idle_accum
	
	# interpolate
	if (prev_position != null):
		if (teleported):
			drawable_node.set_pos(Vector2(0,0))
		else:
			var alpha = new_idle_accum / sixty_fps_frame
			var inverse_alpha = 1 - alpha
			var to_last_pos = prev_position - current_position
			var desired_draw_offset = to_last_pos * inverse_alpha
			drawable_node.set_pos(desired_draw_offset)
	idle_accum = new_idle_accum

func fixed_helper(delta, given_prev_position, given_teleported):
	"""Should be called once during _fixed_process. Needed to know how to interpolate"""
	prev_position = given_prev_position
	teleported = given_teleported