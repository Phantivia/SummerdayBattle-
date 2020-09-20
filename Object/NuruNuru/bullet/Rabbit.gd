extends Node2D
const POWER = 600

func execute():
	if get_parent().has_method("is_hero"):
		get_parent().damaged(POWER)
		get_parent().get_node("warning").visible = false
