# global singleton script for setting screen resolution, position, etc.
# this is done in a global singleton to ensure that, regardless of scene,
# our resolution gets set correctly

extends Node

func _ready():
        var winsize = OS.get_window_size() * 2

        OS.set_window_size(winsize)
        OS.set_window_position((OS.get_screen_size() * 0.5) - (winsize * 0.5))

func get_main():
        return get_parent().get_node("Main")