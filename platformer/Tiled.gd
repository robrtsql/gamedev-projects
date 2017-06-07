extends Node

var levelname = 'testlevel'

func _ready():
	var test_level_json = {}
	var file = File.new()
	file.open('tiled/testlevel/testlevel.json', file.READ)
	test_level_json.parse_json(file.get_as_text())
	file.close()
	for layer in test_level_json['layers']:
		if layer['name'] == 'Object Layer 1':
			for object in layer['objects']:
				print('Adding collision object')
				add_child(_create_collision_object(object))
	pass

func _create_collision_object(object):
	var body = StaticBody2D.new()
	body.set_pos(Vector2(object['x'], object['y']))
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.set_extents(Vector2(object['width']/2, object['height']/2))
	shape.set_shape(rect)
	body.add_child(shape)
	
	## DEBUG
	var x = object['x']
	var y = object['y']
	var w = object['width']
	var h = object['height']
	var drawn_rect = Polygon2D.new()
	drawn_rect.set_polygon([Vector2(x, y), Vector2(x + w, y), Vector2(x + w, y + h), Vector2(x, y + h)])
	add_child(drawn_rect)
	## DEBUG
	
	return body
