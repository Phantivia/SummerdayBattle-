extends Node2D



onready var parent = get_parent()
onready var Bullet_scene = load("res://Object/tea_cup/tea_bullet.tscn")
onready var Magic_scene = load("res://Object/tea_cup/Tea_magic.tscn")
onready var field = get_tree().get_root().get_node("Game").get_node("Field")



var rotdeg = 0
puppet var puppet_rotdeg = 0
var attack_speed = 1
puppet var puppet_attack_speed = 1
onready var hero = get_parent().get_parent()


func _ready():
	hero.health = 700.0
	hero.max_health = 700.0
	hero.armor = 1.1
	pass

func _physics_process(delta):
	if is_network_master():
		#旋转瓶子对准鼠标
		rotdeg = Vector2.UP.angle_to(get_global_mouse_position()-self.global_position)
		$rotate.rotation = rotdeg
		#枪管冷却
		if attack_speed > 1:
			attack_speed -= 0.08 * delta
		
		rset_unreliable("puppet_attack_speed",attack_speed)
		rset_unreliable("puppet_rotdeg",rotdeg)
	else:
		$rotate.rotation = puppet_rotdeg
		
		
	if Input.is_action_pressed("move_shoot") and is_network_master():
		rpc_unreliable("shoot")

func _input(event):
	if Input.is_action_just_pressed("move_skill") and is_network_master() and attack_speed > 0.5:
		rpc("cast_tea_magic",self.global_position)
	pass


remotesync func shoot():
	if not $AnimationPlayer.is_playing():

		if is_network_master():
			if attack_speed < 1.5:
				attack_speed += 0.03
				rset_unreliable("puppet_attack_speed",attack_speed)
		elif not is_network_master():
			attack_speed = puppet_attack_speed

		$AnimationPlayer.playback_speed = attack_speed
		$AnimationPlayer.play("shoot")
		
		var bullet = Bullet_scene.instance()
		bullet.velocity = ($rotate/Position2D.global_position - $rotate/straw.global_position).normalized()
		bullet.rotation = PI + Vector2.UP.angle_to(bullet.velocity)
		bullet.position = $rotate/Position2D.global_position
		field.add_child(bullet)
		$dropping.play()


remotesync func cast_tea_magic(pos):
	if is_network_master():
		attack_speed -= 0.5
		rset("puppet_attack_speed",attack_speed)
	elif not is_network_master():
		attack_speed = puppet_attack_speed

	var magic = Magic_scene.instance()
	magic.position = pos
	magic.scale.x = 0.3
	magic.scale.y = magic.scale.x * 0.5
	field.add_child(magic)
