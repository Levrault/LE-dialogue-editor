# Main container
# Create node and send 
extends Control

onready var graph_edit := $MainWrapper/AppContainer/ViewsContainer/Editor/GraphEditor


func _ready() -> void:
	Events.connect("menu_popup_displayed", self, "_on_Menu_popup_displayed")
	Events.connect("graph_edit_reloaded_started", self, "_on_Graph_edit_reloaded")
	Editor.graph_edit = graph_edit

	if not Config.values.cache.last_opened_file.empty() and Editor.load_last_opened_file:
		Editor.workspace_pristine = false
		Serialize.load(Config.values.cache.last_opened_file.path)
		FileManager.edited_file = Config.values.cache.last_opened_file.duplicate(true)
		FileManager.state = FileManager.State.registred_pristine
		Events.call_deferred("emit_signal", "workspace_files_updated")
	elif Config.values.variables.files.empty() and Editor.workspace_pristine:
		Editor.workspace_pristine = false
		Editor.new_root_node()
		Events.emit_signal("workspace_unsaved_file_added")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		FileManager.clear()
		yield(FileManager, "cache_cleared")
		get_tree().quit()


func _on_Menu_popup_displayed(name: String) -> void:
	assert(has_node(name))
	get_node(name).popup()
