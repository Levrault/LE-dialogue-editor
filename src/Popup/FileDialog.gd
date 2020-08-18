extends FileDialog


func _ready():
	connect("confirmed", self, "_on_Confirmed")
	Events.connect("file_dialog_opened", self, "_on_dialog_opened")


func _on_dialog_opened(new_mode: int) -> void:
	mode = new_mode
	popup()


func _on_Confirmed() -> void:
	print_debug("json will be save inside %s" % current_path)
	print(mode)
	if mode == 0:
		print("in")
		Serialize.load(current_path)
	if mode == 4:
		Serialize.save_as(current_path)
