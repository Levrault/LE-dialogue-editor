extends FileDialog

var initial_file := current_file


func _ready():
	Events.connect("file_dialog_opened", self, "_on_Dialog_opened")
	connect("file_selected", self, "_on_File_selected")
	get_close_button().connect("pressed", self, "_on_Close_pressed")
	get_cancel().connect("pressed", self, "_on_Close_pressed")
	connect("confirmed", self, "_on_Confirmed")
	register_text_enter(get_line_edit())


func _on_Dialog_opened(new_mode: int) -> void:
	mode = new_mode
	current_dir = Config.values.path.resource

	if mode == 0:
		window_title = "Open a file"

	if mode == 2:
		window_title = "Open Workspace"

	if mode == 4:
		window_title = "Save a file"

	if Editor.current_state == Editor.FileState.export_file:
		window_title = "Export a file"
		initial_file = current_file
		if not current_file.empty():
			current_file = current_file.replace(".json", ".min.json")
		else:
			current_file = "new_dialogue.min.json"

	popup()


func _on_Close_pressed() -> void:
	if (
		Editor.current_state == Editor.FileState.export_file
		or Editor.current_state == Editor.FileState.opened
	):
		Editor.current_state = Editor.previous_state


func _on_Confirmed() -> void:
	if mode == 4:
		if Editor.current_state == Editor.FileState.export_file:
			Serialize.save_as(current_path, false)
			current_file = initial_file
			return

		Serialize.save_as(current_path)
		if not Config.values.variables.files.has(current_path):
			Config.values.variables.files.append({path = current_path, name = current_file})
			Config.save(Config.values, Editor.project.project)
			Events.emit_signal("workspace_files_updated")


func _on_File_selected(path: String) -> void:
	if mode == 0:
		Editor.reset()
		yield(Editor, "scene_cleared")
		Serialize.call_deferred("load", current_path)
