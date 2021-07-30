extends VBoxContainer

const MAX_NAME_SIZE := 23

var file_item_scene := preload("res://src/WorkspaceExplorerDrawer/FilesTable/FileItem.tscn")


func _ready() -> void:
	yield(owner, "ready")
	Events.connect("workspace_files_updated", self, "_on_File_updated")
	Events.connect("workspace_unsaved_file_added", self, "_on_Unsaved_file_added")
	_on_File_updated()


static func format_file_name(file_name: String, limit: int) -> String:
	if file_name.length() <= limit:
		return file_name
	return file_name.substr(0, limit) + "[...].json"


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
		var item := file_item_scene.instance()
		add_child(item)
		item.button.values = file
		item.button.text = (
			"%s *" % [format_file_name(file.name, MAX_NAME_SIZE)]
			if FileManager.is_file_dirty(file.path)
			else format_file_name(file.name, MAX_NAME_SIZE)
		)
		item.button.name = file.name
		item.button.align = ToolButton.ALIGN_LEFT
