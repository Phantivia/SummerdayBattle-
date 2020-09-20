extends Label

onready var parent = get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var speed = parent.attack_speed
	self.text = str(speed).pad_decimals(2)
	self.self_modulate.h = speed/1.5 * 140/360
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
