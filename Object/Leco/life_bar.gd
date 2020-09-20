extends Node2D

onready var max_length = $red_bar.scale.x

func update_length(ratio):
	if ratio >= 0:
		$red_bar.scale.x = max_length * ratio
		$red_bar.modulate.h = 100.0/360.0 * ratio
