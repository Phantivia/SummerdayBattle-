extends Label

func _physics_process(delta):
	self.text = str(get_node("../Combo_Timer").time_left)
