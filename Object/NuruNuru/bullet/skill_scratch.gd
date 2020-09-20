extends Node2D
const POWER = 400
var direction = Vector2(0,-1)

func _ready():
	$Area.rotation = Vector2.UP.angle_to(direction)
	$Hand.position = 500* direction
	$Trigger.play("execute")

func trigger():
	var group = $Area/Area2D.get_overlapping_bodies()
	for i in group:
		if i.has_method("is_hero") and i.has_method("damaged"):
			i.damaged(POWER)
	pass
