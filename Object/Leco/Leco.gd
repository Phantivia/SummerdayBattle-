extends KinematicBody2D



var player_name = ""
var flipped = false
var max_health:float = 300.0
var health:float = 300.0
var armor = 1

puppet var puppet_velocity = Vector2(0,0)
puppet var puppet_position = self.position
puppet var puppet_health = 300

onready var animation_state_machine = $AnimationTree.get("parameters/playback")
onready var DamageText_scene = load("res://Object/Class/damage_text.tscn")
onready var neko = get_parent().get_node("Nurunuru")

var SPEED = 120.0
const SPEED_SCALE = 120.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$hero_sprite/name_label.text = player_name
	pass

func _physics_process(delta):
	var velocity = Vector2(0,0)
	if is_network_master():
		if Input.is_action_pressed("move_up"):
			velocity += Vector2.UP
		if Input.is_action_pressed("move_down"):
			velocity += Vector2.DOWN
		if Input.is_action_pressed("move_left"):
			velocity += Vector2.LEFT
		if Input.is_action_pressed("move_right"):
			velocity += Vector2.RIGHT
		velocity = velocity.normalized()
		
		rset_unreliable("puppet_velocity",velocity)
		rset_unreliable("puppet_position",position)
		rset_unreliable("puppet_health",health)
		
	elif not is_network_master():
		velocity = puppet_velocity
		position = puppet_position
		health = puppet_health
	
	$hero_sprite/life_bar.update_length(health/max_health)
	
	if velocity.length() != 0:
		animation_state_machine.travel("run")
	elif velocity.length() == 0:
		animation_state_machine.travel("idle")

	move_and_slide(velocity * SPEED)
	if not is_network_master():
		puppet_position = position 


func _input(_event):
	pass

func set_player_name(player):
	self.player_name = player




func is_hero():
	return true


func healed(damage):

	if is_network_master():
		if health + damage < max_health:
			health += damage
		elif health + damage >= max_health:
			health = max_health
		rset("puppet_health",health)
	elif not is_network_master():
		health = puppet_health
		
	var damage_text = DamageText_scene.instance()
	damage_text.get_node("Label").text = "+" + str(int(damage)) + " !!"
	damage_text.get_node("Label").self_modulate = Color(0.5,1,0.5,1)
	damage_text.rect_scale = Vector2(2,2)
	self.add_child(damage_text)
	
	var ratio = health/max_health
	$hero_sprite/life_bar.update_length(ratio)


func damaged(damage):
	damage *= armor
	if is_network_master():
		health -= damage
		rset("puppet_health",health)
		death_check()
	elif not is_network_master():
		health = puppet_health
		
	var damage_text = DamageText_scene.instance()
	damage_text.get_node("Label").text = str(int(damage)) + " !!"
	damage_text.get_node("Label").self_modulate = Color(1,0.5,0.5,1)
	damage_text.rect_position.x += 100
	damage_text.rect_scale = Vector2(2.2,2.2)
	self.add_child(damage_text)
	
	var ratio = health/max_health
	$hero_sprite/life_bar.update_length(ratio)
	
	$damage_shine.play("shine")

func death_check():
	if self.health <= 0:
		rpc("died")

remotesync func died():
	self.health = -100000.0
	$hero_sprite/life_bar.update_length(0.0)
	$weapon.set_network_master(-1)
	$AnimationTree.active = false
	$AnimationPlayer.play("death")


func lose_check():
	var count = neko.players.size()
	for i in neko.players:
		if i.health <= 0:
			count -= 1
	if count == 0:
		SignalSystem.emit_signal("game_lose")
	SPEED = 0


func realive():
	self.health = self.max_health/2
	$hero_sprite/life_bar.update_length(0.5)
	$AnimationTree.active = true
	$weapon.set_network_master(int(self.name))
	SPEED = SPEED_SCALE
