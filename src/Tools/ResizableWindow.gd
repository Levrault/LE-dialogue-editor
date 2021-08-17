extends Control
class_name ResizableWindow

var _timer :Timer = null


func _ready() -> void:
	connect("resized", self, "_on_Resized")


func save_rect_size() -> void:
	_timer.queue_free()
	Config.globals.info.window_width = int(rect_size.x)
	Config.globals.info.window_height = int(rect_size.y)
	Config.save(Config.globals)


func _on_Resized() -> void:
	if is_instance_valid(_timer):
		_timer.wait_time = .250
		_timer.stop()
		_timer.start()
		return
	_timer = Timer.new()
	add_child(_timer)
	_timer.set_one_shot(true)
	_timer.wait_time = .250
	_timer.connect("timeout", self, "save_rect_size")
	_timer.start()
