extends Node2D

func _ready():
	set_process(true)
	pass

func _process(delta):
	if (Input.is_action_pressed("ui_cancel")):
		get_tree().quit()
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		# TODO: http://docs.godotengine.org/en/latest/learning/features/misc/background_loading.html
		get_node("/root/LoadingScreen").goto_scene("res://Game.tscn", "res://level1.json")
		#get_tree().change_scene("res://Game.tscn")
