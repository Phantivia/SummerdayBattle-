extends Node

onready var parent = get_parent()
onready var animation_state_machine = get_parent().get_node("AnimationTree").get("parameters/playback")

func _logic_process(delta):
	pass


func _get_transition(delta):
	return null


func _enter(old_state):
	pass


func _exit(new_state):
	pass
