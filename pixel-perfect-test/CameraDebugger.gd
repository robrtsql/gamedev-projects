extends Camera2D

var parent_obj = null

func _ready():
	set_process(true)
	parent_obj = get_parent()

func _process(delta):
	var my_global_pos = set_global_pos(parent_obj.get_global_pos())