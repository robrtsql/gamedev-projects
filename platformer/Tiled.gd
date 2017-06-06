extends Node

var levelname = 'testlevel'

func _ready():
	var test_level_json = {}
	var file = File.new()
	file.open('tiled/testlevel/testlevel.json', file.READ)
	test_level_json.parse_json(file.get_as_text())
	file.close()
	for layer in test_level_json['layers']:
		print('layer!')
		if layer['name'] == 'Object Layer 1':
			for object in layer['objects']:
				print('I found an object!!')
				# create a staticbody2D with a collisionshape2D with a rectangle
	pass
