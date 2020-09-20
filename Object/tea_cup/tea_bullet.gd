extends KinematicBody2D

const DAMAGE = 100
const SPEED = 1000
var velocity = Vector2(0,0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	move_and_slide(velocity * SPEED)
	if self.position.length() >= 2000:
		self.queue_free()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.has_method("is_enemy") and body.has_method("damaged"):
		if body.is_enemy():
			body.damaged(DAMAGE ,velocity)
			$AnimationPlayer.play("booom")
	elif body.has_method("is_hero") and body.has_method("healed"):
		if body.is_hero():
			body.healed(DAMAGE * 0.5)
			$AnimationPlayer.play("booom")
	pass # Replace with function body.
