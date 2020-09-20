extends Node2D

onready var max_length = $red_bar.scale.x

func update_length(ratio):
	$red_bar.scale.x = max_length * ratio
