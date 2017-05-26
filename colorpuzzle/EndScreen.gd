extends Node2D

func _ready():
	set_process(true)
	pass

func _process(delta):
	if (Input.is_action_pressed("ui_cancel") or Input.is_mouse_button_pressed(BUTTON_LEFT)):
		get_tree().quit()
