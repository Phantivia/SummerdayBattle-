extends Node2D

var combo_count = 0
puppet var puppet_combo_count = 0
var attack_speed = 0.75
puppet var puppet_attack_speed = 0.75
const POWER = 200
onready var hero = get_parent().get_parent()
onready var Bubble_Scene = load("res://Object/Blue_Snow/bubble.tscn")

var skill_ready = true

func _ready():
	$AnimationPlayer.playback_speed = attack_speed
	hero.max_health = 1000.0
	hero.health = 1000.0
	hero.armor = 0.8

func _input(event):
	if is_network_master():
		if Input.is_action_just_pressed("move_J") and combo_count == 0 and not $AnimationPlayer.is_playing():
			rpc("slash_one")
		elif Input.is_action_just_pressed("move_K") and combo_count == 1 and not $AnimationPlayer.is_playing():
			rpc("slash_two")
		elif Input.is_action_just_pressed("move_L") and Input.is_action_pressed("move_J") and combo_count == 2 and not $AnimationPlayer.is_playing():
			rpc("slash_final")
		if Input.is_action_just_pressed("move_I") and skill_ready:
			rpc("shield_on")
	pass

remotesync func slash_one():
	$AnimationPlayer.play("slash1")
	pass


remotesync func slash_two():
	$AnimationPlayer.play("slash2")
	pass


remotesync func slash_final():
	$AnimationPlayer.play("slash3")
	pass


func slash_check(area_id,damage,combo_invalid = false):
	var group = get_node(area_id).get_overlapping_bodies()
	if group.size() == 0:
		if is_network_master():
			rpc("_on_Combo_Timer_timeout")
		return
	elif group.size() >0:
		
		for i in group:
			if i.has_method("is_enemy") and i.has_method("damaged"):
				i.damaged(damage,Vector2(0,0),"slash")
		if is_network_master() and not combo_invalid:
			rpc("Combo_get")
	pass


remotesync func Combo_get():
	if is_network_master():
		match combo_count:
			0:
				rpc("Label_show","SLASH!")
				combo_count += 1
			1:
				rpc("Label_show","AND!")
				combo_count += 1
			2:
				rpc("Label_show","BREAK!")
				combo_count = 0
				if attack_speed < 1.25:
					attack_speed += 0.25
		rset("puppet_combo_count",combo_count)
		rset("puppet_attack_speed",attack_speed)
	elif not is_network_master():
		combo_count = puppet_combo_count
		attack_speed = puppet_attack_speed
	$AnimationPlayer.playback_speed = attack_speed
	$Combo_Timer.start($Combo_Timer.wait_time)
	pass


remotesync func shield_on():
	if skill_ready:
		var bul = Bubble_Scene.instance()
		get_parent().add_child(bul)
		$Label2.visible = false
		$Skill_TImer.start(15.0)
		skill_ready = false
	pass
	

remotesync func _on_Combo_Timer_timeout():
	if $Label.text != "LOST.." and $Label.text != "" and not $AnimationPlayer.is_playing():
		if is_network_master():
			rpc("Label_show","LOST..")
			combo_count = 0
			if attack_speed >= 0.75:
				attack_speed = 0.75
			rset("puppet_attack_speed",attack_speed)
			rset("puppet_combo_count",combo_count)
		elif not is_network_master():
			attack_speed = puppet_attack_speed
			combo_count = puppet_combo_count
		$AnimationPlayer.playback_speed = attack_speed
	elif $Label.text == "LOST..":
		$Label.text = ""
	pass

func _on_Skill_TImer_timeout():
	skill_ready = true
	$Label2.visible = true
	pass 

remotesync func Label_show(content : String):
	$Label.text = content
	$Label_shine.play("shine")
	pass

