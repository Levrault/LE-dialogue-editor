extends FileDialog

var initial_file := current_file


func _ready():
	Events.connect("file_dialog_opened", self, "_on_Dialog_opened")
	connect("file_selected", self, "_on_File_selected")
	connect("confirmed", self, "_on_Confirmed")
	register_text_enter(get_line_edit())


func _open_file() -> void:
	if Config.has_file_path(current_path):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"%s is already in the workspace" % current_file
		)
		return

	Editor.reset()
	yield(Editor, "scene_cleared")
	yield(get_tree(), "idle_frame")

	Config.values.variables.files.append(
		{name = current_file, path = Editor.resource_path(current_path)}
	)
	Config.values.cache.last_opened_file = {
		name = current_file, path = Editor.resource_path(current_path)
	}
	Config.save(Config.values, Editor.workspace.folder)

	FileManager.state = FileManager.State.registred_pristine
	Serialize.load(current_path, true)
	Events.emit_signal("workspace_files_updated")


func _on_Dialog_opened(new_mode: int) -> void:
	mode = new_mode
	current_dir = Editor.workspace.resource

	if mode == 0:
		window_title = "Open a file"

	if mode == 4:
		window_title = "Save a file"

	popup()


func _on_Confirmed() -> void:
	if mode == 4:
		# Save file with new path
		Serialize.save_as(current_path)

		FileManager.pristine()

		# Set has last opened
		if not Config.has_file_path(current_path):
			Config.values.variables.files.append(
				{name = current_file, path = Editor.resource_path(current_path)}
			)
			Config.values.cache.last_opened_file = {
				name = current_file, path = Editor.resource_path(current_path)
			}
			Config.save(Config.values, Editor.workspace.folder)
			Events.emit_signal("workspace_files_updated")


func _on_File_selected(path: String) -> void:
	if mode == 0:
		_open_file()
