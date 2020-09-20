extends KinematicBody2D

var DAMAGE = 2000
const SPEED = 400
var velocity = Vector2(0,0)

func _ready():
	pass

func _physics_process(delta):
	move_and_slide(velocity * SPEED)
	if self.position.length() >= 2000:
		self.queue_free()



func _on_Area2D_body_entered(body):
	if body.has_method("is_enemy") and body.has_method("damaged"):
		if body.is_enemy():
			body.damaged(DAMAGE,velocity)
			$AnimationPlayer.play("booom")
	pass 
