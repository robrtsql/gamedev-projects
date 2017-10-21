extends AnimationPlayer

# IdempotentPlayer is an AnimationPlayer where
# the "upsert()" method can be used to have an animation
# start playing if and only if it's not already the current
# animation.

func upsert(desired_animation):
	if desired_animation != get_current_animation():
		play(desired_animation)
