# Display all the opened workspace
extends VBoxContainer

var recent_item_scene := preload("res://src/WelcomePage/RecentView/RecentItem.tscn")

var file := File.new()


func _ready() -> void:
	Events.connect("recents_table_changed", self, "_on_recents_table_changed")
	_on_recents_table_changed()


func _on_recents_table_changed() -> void:
	for child in get_children():
		child.queue_free()

	for workspace in Config.globals.workspaces.list:
		var recent_item := recent_item_scene.instance()
		add_child(recent_item)
		recent_item.set_item(workspace)

		recent_item.button.connect("pressed", self, "_on_Pressed", [workspace])


func _on_Pressed(workspace: Dictionary) -> void:
	Config.load_file(workspace.folder)

	var os_resource = workspace.get(OS.get_name())
	if os_resource != null:
		workspace.resource = os_resource
	else:
		# On OSX file extension aren't saved
		if OS.get_name() == "OSX":
			workspace.resource = workspace.folder.rstrip("%s.cfg" % workspace.name)
		else:
			workspace.resource = workspace.folder.rstrip(workspace.name)

	Editor.workspace = workspace
	get_tree().change_scene("res://src/Main/Main.tscn")
