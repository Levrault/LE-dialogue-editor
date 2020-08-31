extends FileDialog


func _ready():
	Events.connect("file_dialog_opened", self, "_on_Dialog_opened")
	connect("file_selected", self, "_on_File_selected")
	get_close_button().connect("pressed", self, "_on_Close_pressed")
	get_cancel().connect("pressed", self, "_on_Close_pressed")
	connect("confirmed", self, "_on_Confirmed")
	register_text_enter(get_line_edit())


func _on_Dialog_opened(new_mode: int) -> void:
	mode = new_mode

	if mode == 0:
		window_title = "Open a file"

	if mode == 4:
		window_title = "Save a file"

	if Editor.current_state == Editor.FileState.export_file:
		window_title = "Export a file"

	popup()


func _on_Close_pressed() -> void:
	if (
		Editor.current_state == Editor.FileState.export_file
		or Editor.current_state == Editor.FileState.opened
	):
		Editor.current_state = Editor.previous_state


func _on_Confirmed() -> void:
	if mode == 4:
		Serialize.save_as(current_path, Editor.current_state != Editor.FileState.export_file)


func _on_File_selected(path: String) -> void:
	if mode == 0:
		Serialize.load(current_path)
