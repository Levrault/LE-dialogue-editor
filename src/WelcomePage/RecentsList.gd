extends VBoxContainer

var button := preload("res://src/Components/AnimatedToolButton.tscn")


func _ready() -> void:
	Events.connect("recents_list_changed", self, "_on_Recents_list_changed")
	_on_Recents_list_changed()


func _on_Recents_list_changed() -> void:
	for child in get_children():
		child.queue_free()

	for workspace in Config.globals.workspaces.list:
		var workspace_button := button.instance()
		add_child(workspace_button)
		workspace_button.align = Button.ALIGN_LEFT
		workspace_button.text = workspace.folder
		workspace_button.connect("pressed", self, "_on_Pressed", [workspace])


func _on_Pressed(workspace: Dictionary) -> void:
	Config.load_file(workspace.folder)
	Editor.workspace = workspace
	get_tree().change_scene("res://src/Main/Main.tscn")
