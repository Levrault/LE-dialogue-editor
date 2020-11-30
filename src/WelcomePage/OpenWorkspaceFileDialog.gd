extends FileDialog


func _ready() -> void:
	Events.connect("workspace_open_file_dialog_displayed", self, "popup")
	connect("file_selected", self, "_on_File_selected")


func _on_File_selected(path: String) -> void:
	Config.globals.workspaces.list.append(
		{folder = path, name = current_file, resource = Config.get_workspace_resource(path)}
	)
	Config.save(Config.globals)
	Events.emit_signal("workspaces_list_changed")
