extends AnimationPlayer

var current_anim

func set_anim(new_anim):
	if (current_anim != new_anim):
		current_anim = new_anim
		play(current_anim)