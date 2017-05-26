extends Node2D

var level = null
var next_level = null
var unscaled_tile_dimensions = Vector2(128, 160)
var tile_dimensions = Vector2(unscaled_tile_dimensions)
var offset = null
var dimensions = {x=5, y=5}
var grid = {}
var drag = null
var mouse_click_down = false
var fade_anim = {
	playing=true,
	current_alpha = 0,
	target_alpha = 1,
	alpha_delta = 0.5
}

func _ready():
	var tile_prefab = preload("res://Prefabs/ColorTile.tscn")
	
	# Adjust for scale
	var tile_instance = tile_prefab.instance()
	tile_dimensions.x = unscaled_tile_dimensions.x * tile_instance.get_scale().x
	tile_dimensions.y = unscaled_tile_dimensions.y * tile_instance.get_scale().y
	
	var viewport_size = get_viewport().get_rect().size
	offset = Vector2(viewport_size.x / 2 - (tile_dimensions.x * dimensions.x / 2) + tile_dimensions.x / 2, 
					 viewport_size.y / 2 - (tile_dimensions.y * dimensions.y / 2) + tile_dimensions.y / 2)
	
	var level_json = {}
	var file = File.new()
	file.open(level, file.READ)
	var json_text = file.get_as_text()
	level_json.parse_json(json_text)
	file.close()
	
	var json_grid = level_json['grid']
	if level_json.has('next_level'):
		next_level = level_json['next_level']
	else:
		next_level = null
	
	for pos in json_grid.keys():
		var split_pos = pos.substr(1, pos.length()-2).split(", ")
		var color_obj = json_grid[pos]
		var vector_pos = Vector2(split_pos[0], split_pos[1])
		_create_tile(tile_prefab, vector_pos, Color(color_obj.r, color_obj.g, color_obj.b, color_obj.a))
	
	# Scramble tiles -- there's no puzzle if the tiles are already all in place!!
	var scrambles = 30
	for i in range(0, scrambles):
		var random_src = get_random_vector()
		var random_dest = get_random_vector()
		if (random_src != null and random_dest != null):
			_swap_tiles(random_src, random_dest)
		else:
			print("Why do we have a null vector?? what the hell")
			print(i)
	
	# Make tiles invisible for fade_in
	set_grid_alpha(0)
	set_process(true)

func _create_tile(tile_prefab, position, color):
	var current_tile = tile_prefab.instance()
	current_tile.set_modulate(color)
	current_tile.set_pos(_get_grid_position(position.x, position.y))
	current_tile.solution_grid_position = position
	grid[position] = current_tile
	add_child(current_tile)

func _get_grid_position(i, j):
	return Vector2(offset.x + tile_dimensions.x * i, offset.y + tile_dimensions.y * j)

func _find_tile(mouse_pos):
	var tile_grid_position = Vector2(0, 0)
	tile_grid_position.x = floor((mouse_pos.x - offset.x + (tile_dimensions.x / 2)) / tile_dimensions.x)
	tile_grid_position.y = floor((mouse_pos.y - offset.y + (tile_dimensions.y / 2)) / tile_dimensions.y)
	return tile_grid_position
	
func get_random_vector():
	var random_i = randi()%dimensions.x
	var random_j = randi()%dimensions.y
	if (random_i == 0 or random_i == dimensions.x-1):
		if (random_j == 0 or random_j == dimensions.y-1):
			return get_random_vector()
	return Vector2(random_i, random_j)

func _swap_tiles(src_grid_position, dest_grid_position):
	if (src_grid_position == null or dest_grid_position == null):
		print("Got null arg!! WTF!!")
	
	var tile_to_swap_with = grid[dest_grid_position]
	var other_tile = grid[src_grid_position]
	
	tile_to_swap_with.set_pos(_get_grid_position(src_grid_position.x, src_grid_position.y))
	grid[src_grid_position] = tile_to_swap_with
	
	other_tile.set_pos(_get_grid_position(dest_grid_position.x, dest_grid_position.y))
	grid[dest_grid_position] = other_tile

func done_playing_anim():
	if (fade_anim.alpha_delta > 0):
		return fade_anim.current_alpha >= fade_anim.target_alpha
	else:
		return fade_anim.current_alpha <= fade_anim.target_alpha

func set_grid_alpha(alpha):
	for pos in grid:
		var color = grid[pos].get_modulate()
		color.a = alpha
		grid[pos].set_modulate(color)

func _goto_next_level():
	if (next_level):
		get_node("/root/LoadingScreen").goto_scene("res://Game.tscn", next_level)
	else:
		get_node("/root/LoadingScreen").goto_scene("res://EndScreen.tscn", null)

func _process(delta):
	if (fade_anim.playing):
		if (done_playing_anim()):
			fade_anim.playing = false
			set_grid_alpha(fade_anim.target_alpha)
			if (fade_anim.target_alpha == 0):
				_goto_next_level()
		else:
			fade_anim.current_alpha += fade_anim.alpha_delta * delta
			set_grid_alpha(fade_anim.current_alpha)
	else:
		if (Input.is_action_pressed("ui_cancel")):
			get_tree().quit()
		if (Input.is_action_pressed("ui_right")):
			fade_anim.playing = true
			fade_anim.target_alpha = 0
			fade_anim.alpha_delta = -0.5
			fade_anim.current_alpha = 1
		if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
			if (drag != null):
				var previous_mouse_pos = drag["mouse_pos"]
				drag["mouse_pos"] = get_viewport().get_mouse_pos()
				var drag_delta = drag["mouse_pos"] - previous_mouse_pos
				drag["tile"].set_pos(drag["tile"].get_pos() + drag_delta)
			else:
				# BEGIN DRAGGING
				if (not mouse_click_down):
					mouse_click_down = true
					var clicked_grid_position = _find_tile(get_viewport().get_mouse_pos())
					if grid.has(clicked_grid_position):
						drag = {
							"grid_position": clicked_grid_position,
							"tile": grid[clicked_grid_position],
							"mouse_pos": get_viewport().get_mouse_pos(),
						}
						drag["tile"].set_z(1)
		else:
			if (drag != null):
				# STOP DRAGGING
				var dest_grid_position = _find_tile(drag["tile"].get_pos())
				
				if (grid.has(dest_grid_position)):
					_swap_tiles(drag["grid_position"], dest_grid_position)
				else:
					drag["tile"].set_pos(_get_grid_position(drag["grid_position"].x, drag["grid_position"].y))
				drag["tile"].set_z(0)
				drag = null
				
				# Check if game is over
				var found_non_match = false
				for position in grid.keys():
					var tile = grid[position]
					if (tile.solution_grid_position != position):
						found_non_match = true
						break
				if (not found_non_match):
					_goto_next_level()
			mouse_click_down = false