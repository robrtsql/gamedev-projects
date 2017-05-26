extends Node2D

func _ready():
	randomize()
	var json_grid = generate_json_grid({"x":5, "y":5})
	var file = File.new()
	file.open("res://level5.json", file.WRITE)
	file.store_string(json_grid)
	file.close()
	set_process(true)

func _process(delta):
	get_tree().quit()

func _get_random_color():
	var r = (randi()%256+1) / 255.0
	var g = (randi()%256+1) / 255.0
	var b = (randi()%256+1) / 255.0
	return Color(r, g, b, 1)

func generate_json_grid(dimensions):
	var json_grid = {}
	var top_left_color = _get_random_color()
	var top_right_color = _get_random_color()
	var bottom_left_color = _get_random_color()
	var bottom_right_color = _get_random_color()
	json_grid[Vector2(0, 0)] = top_left_color
	json_grid[Vector2(dimensions.x-1, 0)] = top_right_color
	json_grid[Vector2(0, dimensions.y-1)] = bottom_left_color
	json_grid[Vector2(dimensions.x-1, dimensions.y-1)] = bottom_right_color
	
	# Top row
	for i in range(1, dimensions.x - 1):
		_create_tile_json(json_grid, i, 0, top_left_color, top_right_color, dimensions.x-1, i)
	# Bottom row
	for i in range(1, dimensions.x - 1):
		_create_tile_json(json_grid, i, dimensions.y-1, bottom_left_color, bottom_right_color, dimensions.x-1, i)
	# Leftmost column
	for j in range(1, dimensions.y - 1):
		_create_tile_json(json_grid, 0, j, top_left_color, bottom_left_color, dimensions.y-1, j)
	# Rightmost column
	for j in range(1, dimensions.y - 1):
		_create_tile_json(json_grid, dimensions.x-1, j, top_right_color, bottom_right_color, dimensions.y-1, j)
	
	var tiles_to_get_list = []
	for i in range(0, dimensions.x):
		for j in range(0, dimensions.y):
			var this_pos = Vector2(i, j)
			if (not json_grid.has(this_pos)):
				tiles_to_get_list.append(this_pos)
	while (tiles_to_get_list.size() != 0):
		var tiles_to_remove_from_list = []
		for tile_to_get in tiles_to_get_list:
			var tiles_created = _interpolate_this_tile(json_grid, tile_to_get, dimensions)
			for tile_created in tiles_created:
				tiles_to_remove_from_list.append(tile_created)
		if (tiles_to_remove_from_list.size() == 0):
			print("Could not create full grid! Not enough tiles predefined.")
			break
		else:
			for tile_to_remove in tiles_to_remove_from_list:
				tiles_to_get_list.remove(tiles_to_get_list.find(tile_to_remove))
	
	for pos in json_grid.keys():
		var color = json_grid[pos]
		json_grid[pos] = {"r":color.r,"g":color.g,"b":color.b,"a":color.a}
	return json_grid.to_json()

func _create_tile_json(json_grid, i, j, color, other_color, distance, color_index):
	var modulate_color = color
	if (other_color != null and distance != null and color_index != null):
		var interpolation_amount = (1.0 / distance) * color_index
		modulate_color = color.linear_interpolate(other_color, interpolation_amount)
	json_grid[Vector2(i, j)] = modulate_color

func _interpolate_this_tile(json_grid, tile_pos, dimensions):
	# Find tiles on either size, aligned horizontally
	var left_tile = null
	var right_tile = null
	for i in range(tile_pos.x-1, -1, -1):
		var this_pos = Vector2(i, tile_pos.y)
		if (json_grid.has(this_pos)):
			left_tile = this_pos
			break
	if (left_tile != null):
		for i in range(tile_pos.x+1, dimensions.x):
			var this_pos = Vector2(i, tile_pos.y)
			if (json_grid.has(this_pos)):
				right_tile = this_pos
				break
		if (right_tile != null):
			return _create_tiles_in_between(json_grid, left_tile, right_tile)
	
	var top_tile = null
	var bottom_tile = null
	for j in range(tile_pos.y-1, -1, -1):
		var this_pos = Vector2(tile_pos.x, j)
		if (json_grid.has(this_pos)):
			top_tile = this_pos
			break
	if (top_tile != null):
		for j in range(tile_pos.y+1, dimensions.y):
			var this_pos = Vector2(tile_pos.x, j)
			if (json_grid.has(this_pos)):
				bottom_tile = this_pos
				break
		if (bottom_tile != null):
			return _create_tiles_in_between(json_grid, top_tile, bottom_tile)
	print("Could not interpolate--no tiles on either side found")
	return []

func _create_tiles_in_between(json_grid, first_pos, second_pos):
	var tiles_created = []
	var first_color = json_grid[first_pos]
	var second_color = json_grid[second_pos]
	if (first_pos.x == second_pos.x):
		var len = second_pos.y - first_pos.y
		for j in range (first_pos.y, second_pos.y):
			if (not json_grid.has(Vector2(first_pos.x, j))):
				_create_tile_json(json_grid, first_pos.x, j, first_color, second_color, len, j)
				tiles_created.append(Vector2(first_pos.x, j))
	elif (first_pos.y == second_pos.y):
		var len = second_pos.x - first_pos.x
		for i in range (first_pos.x, second_pos.x):
			if (not json_grid.has(Vector2(i, first_pos.y))):
				_create_tile_json(json_grid, i, first_pos.y, first_color, second_color, len, i)
				tiles_created.append(Vector2(i, first_pos.y))
	else:
		print("ERROR: _create_tiles_in_between called with misaligned indices")
	return tiles_created