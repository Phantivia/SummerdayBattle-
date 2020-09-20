extends Sprite


onready var timer = get_parent().get_parent().get_node("Timer")

func _process(delta):
	self.region_rect.position.x = 20 + (1.0-timer.time_left/timer.wait_time) * 960
