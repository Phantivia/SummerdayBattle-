extends RemoteTransform2D

onready var boss  = get_tree().get_root().get_node("Game/Field/Players/Nurunuru")

func _process(delta):
	self.global_position = (boss.global_position +get_parent().global_position)/2
