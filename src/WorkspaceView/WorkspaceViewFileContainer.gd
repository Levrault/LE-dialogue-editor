extends VBoxContainer

var workspace_view_button_scene := preload("res://src/WorkspaceView/WorkspaceItemButton.tscn")


func _ready() -> void:
	yield(owner, "ready")
	Events.connect("workspace_files_updated", self, "_on_File_updated")
	Events.connect("workspace_unsaved_file_added", self, "_on_Unsaved_file_added")
	_on_File_updated()


func _on_Unsaved_file_added() -> void:
	FileManager.create_file()
	_on_File_updated()


func _on_File_updated() -> void:
	for child in get_children():
		child.queue_free()

	var merged_files := []
	for file in Config.values.variables.files:
		var has_been_found := false
		for key in FileManager.dirty_registred_files:
			if FileManager.dirty_registred_files[key].path == file.path:
				merged_files.append(FileManager.dirty_registred_files[key])
				has_been_found = true
		if not has_been_found:
			merged_files.append(file)

	var files = merged_files + FileManager.dirty_unregistred_files.values()
	for file in files:
		var button := workspace_view_button_scene.instance()
		button.values = file
		button.text = "%s *" % [file.name] if FileManager.is_file_dirty(file.path) else file.name
		button.name = file.name
		button.align = ToolButton.ALIGN_LEFT
		add_child(button)
