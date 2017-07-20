extends Node

var levelname = 'testlevel'

func _ready():
	var test_level_json = {}
	var file = File.new()
	file.open('tiled/testlevel2/testlevel2.json', file.READ)
	test_level_json.parse_json(file.get_as_text())
	file.close()
	
	var tileset_image = load('textures/spritesheet.png')
	if !(tileset_image extends Texture):
		print("was not a texture!! oh snap!!")
	
	for layer in test_level_json['layers']:
		if layer['name'] == 'Object Layer 1':
			for object in layer['objects']:
				add_child(_create_collision_object(object))
		elif layer['name'] == 'Tile Layer 1':
			var layer_width = layer['width']
			var layer_height = layer['height']
			var data = layer['data']
			var size = data.size()
			for i in range(0, size):
				var x = i % int(layer_width)
				var y = floor(i / layer_width)
				print(x, ',', y)
				add_child(_create_sprite_object(x, y, test_level_json['tilewidth'], test_level_json['tileheight'], data[i], tileset_image))
	#for child in get_children():
	#	print(child)
	pass

func _create_sprite_object(x, y, tile_width, tile_height, tile_index, tileset_image):
	var sprite = Sprite.new()
	sprite.set_pos(Vector2(x * tile_width, y * tile_height))
	sprite.set_texture(tileset_image)
	sprite.set_vframes(30)
	sprite.set_hframes(30)
	sprite.set_frame(tile_index)
	return sprite

func _create_collision_object(object):
	var x = object['x']
	var y = object['y']
	var half_width = object['width']/2
	var half_height = object['height']/2
	var body = StaticBody2D.new()
	body.set_pos(Vector2(x + half_width, y + half_height))
	var rect = RectangleShape2D.new()
	rect.set_extents(Vector2(half_width, half_height))
	body.add_shape(rect)
	
	## DEBUG
	var w = object['width']
	var h = object['height']
	var drawn_rect = Polygon2D.new()
	drawn_rect.set_polygon([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])
	add_child(drawn_rect)
	## DEBUG
	
	return body
