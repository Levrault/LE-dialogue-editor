extends WorkspaceFormDialog


func _ready() -> void:
	connect("file_selected", self, "_on_File_selected")
	disconnect("dir_selected", self, "_on_Dir_selected")


func _on_File_selected(path: String) -> void:
	for workspace in Config.globals.workspaces.list:
		if workspace.folder == path:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"%s already exist in the workspace" % path
			)
			return
	selected_path = path


func _on_Confirmed() -> void:
	if selected_path.empty():
		selected_path = current_path
	field.value = current_path
	owner.form_values.name = current_file
