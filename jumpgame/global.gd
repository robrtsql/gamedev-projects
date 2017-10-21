extends Node

func _ready():
	var winsize = OS.get_window_size() * 1
	
	OS.set_window_size(winsize)
	OS.set_window_position((OS.get_screen_size() * 0.5) - (winsize * 0.5))

func get_main():
	return get_parent().get_node("Main")