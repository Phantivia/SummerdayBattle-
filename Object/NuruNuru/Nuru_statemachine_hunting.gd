extends Node

var target_found = false

onready var parent = get_parent()
onready var animation_state_machine = get_parent().get_node("AnimationTree").get("parameters/playback")
onready var red_eye = get_parent().get_node("Eye")

func _logic_process(delta):
	
	var min_distance = 0
	for i in parent.players:
		var distance = i.global_position.distance_to(parent.global_position)
		if (min_distance ==0 or distance < min_distance) and i.health > 0:
			parent.target = i
			min_distance = distance
	red_eye.set_target(parent.target)
	
	if is_network_master():
		parent.velocity = parent.global_position.direction_to(red_eye.global_position)
		parent.rset_unreliable("puppet_velocity",parent.velocity)
		parent.rset_unreliable("puppet_position",parent.position)
	elif not is_network_master():
		parent.velocity = parent.puppet_velocity


	parent.move_and_slide(parent.velocity * parent.speed_rate)
	if not is_network_master():
		parent.position = parent.puppet_position
	
	pass


func _get_transition(delta):
	var transition = null
	if target_found:
		transition = "attacking"
	return transition


func _enter(old_state):
	
	animation_state_machine.travel("run")
	target_found = false
	red_eye.visible = true
	
	for i in parent.get_node("attack_area").get_overlapping_bodies():
		if i.has_method("is_hero"):
			parent.target = i
			target_found = true
			break
	pass


func _exit(new_state):
	pass




func _on_attack_area_body_entered(body):
	target_found = true
	pass # Replace with function body.
