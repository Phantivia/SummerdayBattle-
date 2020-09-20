extends Node2D
const POWER = 1200.0

func boom():
	var group = []
	for i in $Area2D.get_overlapping_bodies():
		if i.has_method("is_hero") and i.health > 0:
			group.append(i)
	if group.size() != 0:
		for i in group:
			if i.has_method("damaged"):
				i.damaged(POWER/group.size())
	pass
