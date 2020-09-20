extends Node
class_name StateMachine

onready var parent = get_parent()

var previous_state = null
var current_state = null
puppet var puppet_current_state = null

var states = []


func _physics_process(delta):
	if current_state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		if transition != null and is_network_master():
			rpc("set_state",transition)


func _state_logic(delta):
	pass



func _exit_state(old_state,new_state):
	pass


func _enter_state(old_state,new_state):
	pass


func _get_transition(delta):
	return null


remotesync func set_state(new_state:String):
	
	previous_state = current_state
	current_state  = new_state
	
	if previous_state != null:
		_exit_state(previous_state,current_state)
	if current_state != null:
		_enter_state(previous_state,current_state)


func initialize(states_array,start_state):
	if states_array != null:
		states = states_array
	if start_state != null:
		set_state(start_state)
	
puppet func update_state(state : String):
	return
