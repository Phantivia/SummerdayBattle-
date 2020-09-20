extends Node2D
const POWER = 400

onready var neko = get_parent().get_parent()

func run():
	$AnimationPlayer.play("build")

func execute():
	var group = []
	
	for i in $Area2D1.get_overlapping_bodies():
		if i.has_method("is_hero"):
			group.append(i)
	
	for i in $Area2D2.get_overlapping_bodies():
		if i.has_method("is_hero"):
			group.erase(i)
	
	for i in group:
		if i.has_method("damaged"):
			i.damaged(POWER)

func play_rotate():
	neko.get_node("movement").play("rotate")
