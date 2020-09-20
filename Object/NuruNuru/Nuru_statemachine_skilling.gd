extends Node

onready var parent = get_parent()
onready var animation_state_machine = get_parent().get_node("AnimationTree").get("parameters/playback")
onready var base = $Nuru_statemachine_skilling_base
onready var skill_timer = get_parent().get_node("Skill_Timer")

var skill = null
var loading = false
var casting = false

func _logic_process(delta):
	if skill != null :
		var method_name = "_"+skill+"_logic_process"
		if base.has_method(method_name):
			base.call(method_name,delta)
	pass


func _get_transition(delta):
	var transition = null
	
	if skill != null :
		var method_name = "_"+skill+"_get_transition"
		if base.has_method(method_name):
			transition = base.call(method_name,delta)
			
	return transition

func _enter(old_state):
	if skill != null :
		var method_name = "_"+skill+"_enter"
		if base.has_method(method_name):
			base.call(method_name,old_state)
	pass


func _exit(new_state):
	var next_skill_time = 10.0
	if skill != null :
		var method_name = "_"+skill+"_exit"
		if base.has_method(method_name):
			next_skill_time = base.call(method_name,new_state)
			
	skill = null
	loading = false
	casting = false
	
	skill_timer.wait_time = next_skill_time
	skill_timer.start()
	pass
