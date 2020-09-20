extends Sprite
onready var parent = get_parent()

func deal_damage():
	if parent != null and parent.has_method("damaged") and parent.health > 0:
		parent.damaged(100)
