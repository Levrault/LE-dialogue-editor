extends FileDialog


func _ready():
	Events.connect("file_dialog_opened", self, "_on_dialog_opened")
	connect("file_selected", self, "_on_File_selected")
	connect("confirmed", self, "_on_Confirmed")
	register_text_enter(get_line_edit())


func _on_dialog_opened(new_mode: int) -> void:
	mode = new_mode
	popup()


func _on_Confirmed() -> void:
	if mode == 4:
		Serialize.save_as(current_path)


func _on_File_selected(path: String) -> void:
	if mode == 0:
		Serialize.load(current_path)
