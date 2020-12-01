extends FileDialog


func _ready() -> void:
	Events.connect("workspace_open_file_dialog_displayed", self, "popup")
	connect("file_selected", self, "_on_File_selected")


func _on_File_selected(path: String) -> void:
	for workspace in Config.globals.workspaces.list:
		print(workspace)
		if workspace.folder == path:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"%s already exist in the workspace" % path
			)
			return

	Config.globals.workspaces.list.append(
		{folder = path, name = current_file, resource = Config.get_workspace_resource(path)}
	)
	Config.save(Config.globals)
	Events.emit_signal("recents_list_changed")
