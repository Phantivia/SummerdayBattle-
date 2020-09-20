extends Node2D

var count = 0
onready var Danmaku_Scene = load("res://Object/NuruNuru/bullet/danmaku.tscn")
onready var neko = get_parent().get_parent()



func _on_Timer_timeout():
	if count > 0 :
		for i in neko.players:
			var dan = Danmaku_Scene.instance()
			var distance = (i.position - neko.position).length()
			var speed_rate = 30
			if distance >= 200:
				speed_rate = 30
			else:
				speed_rate = pow(distance,3) * 10.0/(200.0*200.0*200.0)
			dan.velocity = (i.position - neko.position).normalized() * speed_rate
			print(distance)
			print(speed_rate)
			dan.scale *= 2
			dan.position = neko.position
			neko.get_parent().add_child(dan)
		count -=1
	else:
		self.queue_free()
	pass 
