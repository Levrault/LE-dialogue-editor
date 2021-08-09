extends WorkspaceFormDialog


func _on_File_selected(path: String) -> void:
	for workspace in Config.globals.workspaces.list:
		if workspace.folder == path:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"%s already exist in the workspace" % path
			)
			return

	var file = Config.read_workspace_file(path)

	# Config.globals.workspaces.list.append(
	# 	{
	# 		folder = path,
	# 		name = current_file,
	# 		resource = file.get_value("path", "resource", path),
	# 		has_portrait = file.get_value("configuration", "has_portrait", true),
	# 		has_name = file.get_value("configuration", "has_name", true)
	# 	}
	# )
	# Config.save(Config.globals)
	# Events.emit_signal("recents_table_changed")
