extends Light2D

func _process(delta):
	self.scale.y = 55 * (0.7-get_node("../Combo_Timer").time_left)/0.7
