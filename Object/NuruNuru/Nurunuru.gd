extends KinematicBody2D


onready var DamageText_scene = load("res://Object/NuruNuru/damage_text.tscn")

var skill_list = {"big_scratch":5,"fish_boom":5,"moon_jump":5,"red_harzard":5,"danmaku_load":5}
var players = []
var target:KinematicBody2D
var speed_rate = 100
var died = false

const max_health = 200000.0

var health = 200000.0
puppet var puppet_health = 200000.0

var velocity = Vector2(0,0)
puppet var puppet_velocity = Vector2(0,0)

puppet var puppet_position = self.position


func _ready():

	self.set_network_master(1)


func _physics_process(delta):
	if is_network_master():
		rset_unreliable("puppet_position",position)
	elif not is_network_master():
		position = puppet_position
	

func damaged(damage,velo = Vector2(0,0),type = "none"):
	
	if is_network_master():
		health -= damage
		rset("puppet_health",health)
	elif not is_network_master():
		health = puppet_health
	
	var health_ratio = health/max_health
	$life_bar.update_length(health_ratio)

	#如果伤害够高，加载伤害显示文本
	if damage >= 200 or type == "slash":
		var damage_text = DamageText_scene.instance()
		damage_text.get_node("Label").text = str(int(damage)) + " !!"
		var damage_scale = pow(damage/200,0.6)
		damage_text.rect_scale = Vector2(damage_scale,damage_scale)
		self.add_child(damage_text)
		if type == "slash":
			$axe.play("axe")
			$wounded.play()
	$AnimationPlayer.play("hit")
	check_win()


func is_enemy():
	return true


func _on_Skill_Timer_timeout():
	$Skill_Timer.stop()
	$Nuru_statemachine_skilling/Nuru_statemachine_skilling_base.SKILL_RATE = 1 *pow(max_health/(50000.0+health), 1/3.5)
	print($Nuru_statemachine_skilling/Nuru_statemachine_skilling_base.SKILL_RATE)
	if is_network_master() and health >0:
		var chosen_skill = random_choose_skill()
		if chosen_skill != null:
			$Nuru_statemachine.rpc("set_state","skilling",chosen_skill)
	pass


func random_choose_skill() -> String:
	randomize()
	var skill_box = []
	for sk in skill_list:
		for i in range(skill_list[sk]):
			skill_box.append(sk)
	skill_box.shuffle()
	return skill_box[0]
	
func check_win():
	if self.health >0 or died:
		return
	elif self.health <=0 and not died:
		$Nuru_statemachine.set_state("await")
		$AnimationTree.active = false
		$life_bar.visible = false
		$Eye.visible = false
		$AnimationPlayer.play("win")
		

func henshin():
	$cat_body.texture = load("res://Object/NuruNuru/the cat alter.png")
	$cat_body/cat_tail.texture = load("res://Object/NuruNuru/the cat alter_tail.png")
	SignalSystem.emit_signal("game_win")
