extends ResizableWindow


func _ready():
	OS.window_size = Vector2(Config.globals.info.window_width, Config.globals.info.window_height)
	OS.center_window()
