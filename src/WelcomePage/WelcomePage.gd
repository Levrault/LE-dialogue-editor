extends Control


func _ready():
	if not Editor.active_fullscreen:
		return
	OS.center_window()
	# OS.set_window_maximized(true)
	# Editor.active_fullscreen = false
