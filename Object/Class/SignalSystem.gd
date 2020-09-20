extends Node


signal start_loading(text,time)
signal loading_completed
signal game_win
signal game_lose
signal warning_text(text)


remotesync func remote_loading(text,time):
	emit_signal("start_loading",text,time)
