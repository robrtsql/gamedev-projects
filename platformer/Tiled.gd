extends Node

var levelname = 'testlevel'
var player_scene = preload('res://scenes/Player.tscn')

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
				if data[i] != 0:
					add_child(_create_sprite_object(x, y, test_level_json['tilewidth'], test_level_json['tileheight'], data[i], tileset_image))
		elif layer['name'] == 'Object Layer 2':
			for object in layer['objects']:
				add_child(_create_player_object(object['x'], object['y']))
	pass

func _create_player_object(x, y):
	var player_obj = player_scene.instance()
	player_obj.set_pos(Vector2(x, y))
	var camera = Camera2D.new()
	camera.set_zoom(Vector2(0.5, 0.5))
	camera.make_current()
	player_obj.add_child(camera)
	return player_obj

func _create_sprite_object(x, y, tile_width, tile_height, tile_index, tileset_image):
	var sprite = Sprite.new()
	sprite.set_pos(Vector2(x * tile_width + (tile_width / 2), y * tile_height + (tile_height / 2)))
	sprite.set_texture(tileset_image)
	sprite.set_vframes(30)
	sprite.set_hframes(30)
	sprite.set_frame(tile_index - 1)
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
	return body
