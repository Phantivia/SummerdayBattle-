extends StateMachine


onready var await = get_node("../Nuru_statemachine_await")
onready var hunting = get_node("../Nuru_statemachine_hunting")
onready var attacking = get_node("../Nuru_statemachine_attacking")
onready var skilling = get_node("../Nuru_statemachine_skilling")


func _ready():
	initialize(["await","hunting","attacking","skilling"],"await")
	#初始化所有状态，设定await为初始状态
	pass


func _state_logic(delta):
	
	#同步boss位置
	if is_network_master():
		parent.rset_unreliable("puppet_position",parent.position)
	elif not is_network_master():
		parent.position = parent.puppet_position

	match current_state:
		"await":
			await._logic_process(delta)
		"hunting":
			hunting._logic_process(delta)
		"attacking":
			attacking._logic_process(delta)
		"skilling":
			skilling._logic_process(delta)
	pass


func _get_transition(delta):
	var transition = null
	match current_state:
		"await":
			transition = await._get_transition(delta)
		"hunting":
			transition = hunting._get_transition(delta)
		"attacking":
			transition = attacking._get_transition(delta)
		"skilling":
			transition = skilling._get_transition(delta)
	return transition


func _exit_state(old_state,new_state):
	match old_state:
		"await":
			await._exit(new_state)
		"hunting":
			hunting._exit(new_state)
		"attacking":
			attacking._exit(new_state)
		"skilling":
			skilling._exit(new_state)
	pass


func _enter_state(old_state,new_state):
	match new_state:
		"await":
			await._enter(old_state)
		"hunting":
			hunting._enter(old_state)
		"attacking":
			attacking._enter(old_state)
		"skilling":
			skilling._enter(old_state)
	pass


remotesync func set_state(new_state:String,cast_skill = null):
	if cast_skill != null:
		skilling.skill = cast_skill
	
	previous_state = current_state
	current_state  = new_state
	
	if previous_state != null:
		_exit_state(previous_state,current_state)
	if current_state != null:
		_enter_state(previous_state,current_state)


