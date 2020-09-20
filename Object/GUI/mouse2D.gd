extends Sprite

func _ready():
	if not is_network_master():
		self.visible = false

func _process(delta):
	if is_network_master():
		self.global_position = get_global_mouse_position()
