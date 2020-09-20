extends Node2D

onready var parent = get_parent()
onready var Rabbit_Scene = load("res://Object/NuruNuru/bullet/Rabbit.tscn")
const POWER = 400

var type = "X"
var targeted = false


func _physics_process(delta):
	
	if not targeted and(type == "X" or type == "Y"):
		if type == "X":
			$rotate.rotation_degrees = 3 * int(parent.position.x)		
		if type == "Y":
			$rotate.rotation_degrees =3 * int(parent.position.y)

func execute():
	targeted = true
	var group = []
	for i in $rotate/Area2D.get_overlapping_bodies():
		if i.has_method("is_hero") and i.health > 0:
			group.append(i)
	print(group)
	for i in group:
		if i.has_method("is_hero") and i.health > 0:
			var rab = Rabbit_Scene.instance()
			i.add_child(rab)


func _on_Area2D_body_entered(body):
	if body.has_method("is_hero"):
		body.get_node("warning").visible = true
	pass


func _on_Area2D_body_exited(body):
	if body.has_method("is_hero"):
		body.get_node("warning").visible = false
	pass # Replace with function body.
