extends Node

onready var parent = get_parent()
onready var neko = get_parent().get_parent()
onready var skill_container = get_parent().get_parent().get_node("Skill_Container")
onready var animation_state_machine = get_parent().get_parent().get_node("AnimationTree").get("parameters/playback")

onready var Big_Scratch_Scene = load("res://Object/NuruNuru/bullet/skill_scratch.tscn")
onready var Fish_Boom_Scene = load("res://Object/NuruNuru/bullet/Fish_boom.tscn")
onready var Moon_Jump_Scene = load("res://Object/NuruNuru/bullet/Monn_jump.tscn")
onready var Red_Harzard_Scene = load("res://Object/NuruNuru/bullet/Red_hazard.tscn")
onready var Danmaku_Load_Scene = load("res://Object/NuruNuru/bullet/danmaku_shooter.tscn")

var finished = false
var SKILL_RATE = 1.0
var loaded = false
var time_gap_cache = 10.0
var chosen_one = -1
puppet var puppet_chosen_one = -1

func _ready():
	SignalSystem.connect("loading_completed",self,"_on_loading_completed")

func _on_loading_completed():
	loaded = true

#小扇形aoe
func _big_scratch_enter(old_state):
	#这个技能只在attacking状态发动
	if old_state != "attacking" or neko.target == null:
		finished = true
		time_gap_cache = 1.0
		return
	
	else:
		var scratch = Big_Scratch_Scene.instance()
		scratch.direction = neko.position.direction_to(neko.target.position)
		skill_container.add_child(scratch)
		finished = true
		time_gap_cache = 5.0
		return

func _big_scratch_get_transition(delta):
	var transition = null
	if finished:
		transition = "hunting"
	return transition

func _big_scratch_exit(new_state):
	finished = false
	if neko.skill_list["big_scratch"] == 100:
		neko.skill_list["big_scratch"] = 5
	return time_gap_cache/SKILL_RATE
	
#分摊aoe
func _fish_boom_enter(old_state):
	
	finished = false
	loaded = false
	SignalSystem.emit_signal("start_loading","宿醉的费事",1.5)
	
	if is_network_master():
		randomize()
		chosen_one = randi()%(neko.players.size())
		
		while neko.players[chosen_one].health <0 and neko.players.size() != 1:
			print(neko.players[chosen_one].health)
			chosen_one += 1
			if chosen_one == neko.players.size():
				chosen_one = 0
				
		rset("puppet_chosen_one",chosen_one)
		
	neko.get_node("angry1").play()

func _fish_boom_get_transition(delta):
	var transition = null
	
	if finished:
		transition = "hunting"
		
	return transition

func _fish_boom_logic_process(delta):
	if loaded:
		if not is_network_master():
			chosen_one = puppet_chosen_one
		if not finished and chosen_one != -1:
			var boomer = Fish_Boom_Scene.instance()
			neko.players[chosen_one].add_child(boomer)
			finished = true

func _fish_boom_exit(new_state):
	finished = false
	loaded = false
	chosen_one = -1
	puppet_chosen_one = -1
	if neko.skill_list["fish_boom"] == 5:
		neko.skill_list["fish_boom"] = 1
	elif neko.skill_list["fish_boom"] == 1:
		neko.skill_list["fish_boom"] = 5
	return 3/SKILL_RATE

#月环
func _moon_jump_enter(old_state):
	
	var jump = Moon_Jump_Scene.instance()
	jump.name = "moon_jump"
	skill_container.add_child(jump)
	
	SignalSystem.emit_signal("start_loading","钢之月面宙返",2.0)
	
	animation_state_machine.travel("idle")
	neko.get_node("angry2").play()

func _moon_jump_logic_process(delta):
	if loaded:
		skill_container.get_node("moon_jump").run()
		loaded = false
		
	if skill_container.get_child_count() == 0:
		finished = true

func _moon_jump_get_transition(delta):
	var transition = null
	
	if finished:

		transition = "hunting"
	
	return transition

func _moon_jump_exit(new_state):
	neko.skill_list["big_scratch"] = 100
	finished = false
	loaded = false
	chosen_one = -1
	puppet_chosen_one = -1
	if neko.skill_list["moon_jump"] == 5:
		neko.skill_list["moon_jump"] = 1
	elif neko.skill_list["moon_jump"] == 1:
		neko.skill_list["moon_jump"] = 5
	return 0.5
#Red harzard

func _red_harzard_enter(old_state):
	randomize()
	animation_state_machine.travel("tail_fan")
	var xy = ["X","Y"]
	if is_network_master():
		chosen_one = xy[randi()%2]
		rset("puppet_chosen_one",chosen_one)
		SignalSystem.rpc("remote_loading","红色警戒~信号"+chosen_one,3)

func _red_harzard_logic_process(delta):
	if not loaded and not finished:
		if is_network_master():
			rset_unreliable("puppet_chosen_one",chosen_one)
		elif not is_network_master():
			chosen_one = puppet_chosen_one

	if loaded and not finished:
		for i in neko.players:
			var red = Red_Harzard_Scene.instance()
			red.type = chosen_one
			i.add_child(red)
		finished = true

func _red_harzard_get_transition(delta):
	var transition = null
	
	if finished:
		transition = "hunting"
	
	return transition

func _red_harzard_exit(new_state):
	finished = false
	loaded = false
	chosen_one = -1
	puppet_chosen_one = -1
	if neko.skill_list["red_harzard"] == 5:
		neko.skill_list["red_harzard"] = 1
	elif neko.skill_list["red_harzard"] == 1:
		neko.skill_list["red_harzard"] = 5
	return 5/SKILL_RATE
	
#装填弹幕
func _danmaku_load_enter(old_state):
	animation_state_machine.travel("idle")
	SignalSystem.emit_signal("start_loading","弹幕装载",2.0)
	SignalSystem.emit_signal("warning_text","费事猫瞄准了远处的敌人...")
	
func _danmaku_load_logic_process(delta):
	if loaded and not finished:
		var sho = Danmaku_Load_Scene.instance()
		sho.count = 4
		skill_container.add_child(sho)
		finished = true

func _danmaku_load_get_transition(delta):
	var transition = null
	if finished:
		transition = "hunting"
	return transition

func _danmaku_load_exit(new_state):
	finished = false
	loaded = false
	chosen_one = -1
	puppet_chosen_one = -1
	
	if neko.skill_list["danmaku_load"] == 5:
		neko.skill_list["danmaku_load"] = 1
		
	elif neko.skill_list["danmaku_load"] == 1:
		neko.skill_list["danmaku_load"] = 5
	
	return 5/SKILL_RATE
		
