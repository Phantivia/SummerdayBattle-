extends AnimatedSprite

var memory = Vector2(0,0)
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	liquid_rotate()
	liquid_inertia()

func liquid_rotate():
	self.position.y =  330 - 0.9*(abs(abs(int(get_node("../rotate").rotation_degrees) %360)- 180)+180) * 0.15

func liquid_inertia():
	if memory.x != get_global_position().x:
		if memory.x > get_global_position().x:
			self.rotation_degrees = lerp(self.rotation_degrees,-15,0.1)
		if memory.x < get_global_position().x:
			self.rotation_degrees = lerp(self.rotation_degrees,15,0.1)
	else:
		self.rotation_degrees = lerp(self.rotation_degrees,0,0.1)
	memory = get_global_position()
	pass
