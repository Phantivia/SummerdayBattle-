extends KinematicBody2D
var armor = 1.0


func is_hero():
	return true

func damaged(POWER,velo = Vector2(0,0)):
	$shine.play("shine")
	pass

func _on_Area2D_body_entered(body):
	if body.has_method("is_hero"):
		body.armor *= 0.6
	pass 
	


func _on_Area2D_body_exited(body):
	if body.has_method("is_hero"):
		body.armor /= 0.6
	pass

func quit():
	self.queue_free()
