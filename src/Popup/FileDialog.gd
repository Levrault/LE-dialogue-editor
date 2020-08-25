extends FileDialog


func _ready():
	connect("confirmed", self, "_on_Confirmed")
	connect("file_selected", self, "_on_File_selected")
	Events.connect("file_dialog_opened", self, "_on_dialog_opened")
	register_text_enter(get_line_edit())


func _on_dialog_opened(new_mode: int) -> void:
	mode = new_mode
	popup()


func _on_Confirmed() -> void:
	print_debug("json will be save inside %s" % current_path)
	if mode == 0:
		Serialize.load(current_path)
	if mode == 4:
		Serialize.save_as(current_path)


func _on_File_selected(path: String) -> void:
	if mode == 0:
		Serialize.load(current_path)
