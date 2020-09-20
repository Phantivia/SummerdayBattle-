extends Node

onready var parent = get_parent()
onready var animation_state_machine = get_parent().get_node("AnimationTree").get("parameters/playback")
onready var triggered = false

func _logic_process(delta):
	pass


func _get_transition(delta):
	var transition = null
	if parent.health < parent.max_health and not triggered:
		transition = "hunting"
		triggered = true
	return transition


func _enter(old_state):

	pass


func _exit(new_state):
	parent.get_node("bgm").play()
	parent.get_node("Skill_Timer").start()
	var group = parent.get_parent().get_parent().get_node("Players").get_children()
	for i in group:
		if i.has_method("is_hero"):
			parent.players.append(i)
	pass
