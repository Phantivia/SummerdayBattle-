extends Node

var actived = false

onready var parent = get_parent()
onready var animation_state_machine = get_parent().get_node("AnimationTree").get("parameters/playback")
onready var red_eye = get_parent().get_node("Eye")
onready var Hand_scene = load("res://Object/NuruNuru/bullet/Cat_Hand.tscn")

func _logic_process(delta):
	pass


func _get_transition(delta):
	var transition = null
	if parent.global_position.distance_to(parent.target.global_position) >= 100:
		transition = "hunting"
	if parent.target.health < 0:
		transition = "hunting"

	return transition


func _enter(old_state):
	$attack_timer.start()
	self.actived = true
	pass


func _exit(new_state):
	self.actived = false
	pass


func _on_attack_timer_timeout():
	if self.actived:
		var hand = Hand_scene.instance()
		if parent.target.health > 0:
			parent.target.add_child(hand)
	pass # Replace with function body.
