extends Node2D

var POWER = 100

func _ready():
	$Magic.playback_speed = 1.5
	
func healing():
	var group = $Area2D.get_overlapping_bodies()
	for i in group:
		if i.has_method("is_hero") and i.has_method("healed"):
			i.healed(POWER)
