# Display all the opened workspace
# If the file's os path doesn't exist, it will be updated
extends VBoxContainer

var button := preload("res://src/Generic/AnimatedToolButton.tscn")

var file := File.new()


func _ready() -> void:
	Events.connect("recents_list_changed", self, "_on_Recents_list_changed")
	_on_Recents_list_changed()


func _on_Recents_list_changed() -> void:
	for child in get_children():
		child.queue_free()

	for workspace in Config.globals.workspaces.list:
		if not file.file_exists(workspace.folder):
			continue

		var workspace_button := button.instance()
		add_child(workspace_button)
		workspace_button.align = Button.ALIGN_LEFT
		workspace_button.text = workspace.folder
		workspace_button.connect("pressed", self, "_on_Pressed", [workspace])


func _on_Pressed(workspace: Dictionary) -> void:
	Config.load_file(workspace.folder)
	var os_resource = workspace.get(OS.get_name())
	if os_resource != null:
		workspace.resource = os_resource
	else:
		# workspace has been created from another os
		workspace.resource = workspace.folder.rstrip(workspace.name)
	Editor.workspace = workspace
	print_debug(Editor.workspace)
	get_tree().change_scene("res://src/Main/Main.tscn")
