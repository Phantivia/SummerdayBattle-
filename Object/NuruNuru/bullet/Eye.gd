extends Node2D

var target:KinematicBody2D = null

func set_target(tag):
	target = tag
	
func _physics_process(delta):
	if target != null:
		self.global_position = target.global_position
