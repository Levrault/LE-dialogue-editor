extends VBoxContainer

var animated_button_scene := preload("res://src/Components/AnimatedToolButton.tscn")


func _ready() -> void:
	Events.connect("workspace_files_updated", self, "_on_File_updated")
	_on_File_updated()


func _on_File_updated() -> void:
	for child in get_children():
		child.queue_free()
	for file in Config.values.variables.files:
		var button := animated_button_scene.instance()
		button.text = file.name
		button.name = file.name
		button.align = ToolButton.ALIGN_LEFT
		button.connect("pressed", self, "_on_File_pressed", [file])
		add_child(button)
		button.selected = Config.values.cache.last_opened_file == file.path


func _on_File_pressed(file: Dictionary) -> void:
	# if Editor.current_state == Editor.FileState.new:
	# 	print(Editor.workspace)
	# 	Temp.create(Editor.workspace.name)
	# 	yield(Temp, "temp_file_created")
	Editor.reset()
	yield(Editor, "scene_cleared")
	Serialize.call_deferred("load", file.path)
	Config.values.cache.last_opened_file = file.path
	Config.save(Config.values, Editor.workspace.folder)
	_on_File_updated()
