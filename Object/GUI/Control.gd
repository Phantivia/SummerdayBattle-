extends Control

func _ready():
	SignalSystem.connect("start_loading",self,"_on_start_loading")
	SignalSystem.connect("game_win",self,"_on_game_win")
	SignalSystem.connect("warning_text",self,"_on_warning_text")
	SignalSystem.connect("game_lose",self,"_on_game_lose")

func _on_start_loading(_text,_time):
	$Timer.wait_time = _time
	$Timer.start()
	$box/Label.text = _text
	$AnimationPlayer.play("floating_up")


func _on_Timer_timeout():
	SignalSystem.emit_signal("loading_completed")
	$AnimationPlayer.play_backwards("floating_up")
	pass

func _on_game_win():
	$AnimationPlayer.play("win")

func _on_warning_text(text):
	$warning_label.text = text
	$warning_label/AnimationPlayer.play("warning")

func _on_game_lose():
	for i in get_parent().get_parent().get_node("Field/Players/Nurunuru").players:
		i.get_node("AnimationPlayer").stop(true)
	$Node2D/complete.text = "使命失败.."
	$Node2D.modulate.s = 0
	$AnimationPlayer.play("win")
