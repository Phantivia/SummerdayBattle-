extends Label

onready var parent = get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	var speed = parent.attack_speed
	self.text = str(speed).pad_decimals(2)
	$Shake.playback_speed = pow(speed,2.5)
	self.modulate.b = 1 - (speed-1) *0.5
	self.modulate.g = 1 - (speed-1) *0.5
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
