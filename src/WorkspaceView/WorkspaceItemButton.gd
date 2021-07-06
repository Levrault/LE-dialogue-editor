extends AnimatedToolButton

signal values_changed

var values := {} setget set_values


func _ready() -> void:
	Events.connect("workspace_file_selection_changed", self, "_on_Workspace_file_selection_changed")
	connect("pressed", self, "_on_Pressed")


func set_values(new_values: Dictionary) -> void:
	values = new_values
	if Serialize.current_path == Editor.absolute_path(values.path):
		self.selected = true
		FileManager.edited_file = {path = values.path, name = values.name, button_ref = self}
	emit_signal("values_changed")


func _on_Workspace_file_selection_changed(ref: AnimatedToolButton) -> void:
	self.selected = (self == ref)


func _on_Pressed() -> void:
	Events.emit_signal("spinner_displayed")
	if FileManager.state == FileManager.State.unregistred_dirty:
		Serialize.save()
		print_debug(
			"%s has been cached inside %s" % [FileManager.edited_file.path, Serialize.current_path]
		)
	else:
		FileManager.cache_file()

	# load an existing file
	Editor.reset()
	yield(Editor, "scene_cleared")
	yield(get_tree(), "idle_frame")
	print(Store.root_node)

	if values.has("unregistred"):
		Serialize.load(Editor.absolute_path(values.path), true)
		FileManager.state = FileManager.State.unregistred_dirty
	elif values.has("cache_path"):
		Serialize.load(values.cache_path, true)
		FileManager.state = FileManager.State.registred_dirty
	else:
		Config.values.cache.last_opened_file = {
			name = values.name, path = Editor.absolute_path(values.path)
		}
		Config.save(Config.values, Editor.workspace.folder)
		FileManager.state = FileManager.State.registred_pristine
		Serialize.load(Editor.absolute_path(values.path), false)

	FileManager.edited_file = {path = values.path, name = values.name, button_ref = self}
	Events.emit_signal("workspace_file_selection_changed", self)
	Events.call_deferred("emit_signal", "spinner_hidden")
