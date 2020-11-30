extends FileDialog

var field = null
var selected_path := ''


func _ready() -> void:
	Events.connect(
		"workspace_new_file_dialog_displayed", self, "_on_Workspace_new_file_dialog_displayed"
	)
	connect("dir_selected", self, "_on_Dir_selected")
	connect("confirmed", self, "_on_Confirmed")


func _on_Workspace_new_file_dialog_displayed(node) -> void:
	popup()
	field = node


func _on_Confirmed() -> void:
	if selected_path.empty():
		selected_path = current_dir
	field.value = selected_path


func _on_Dir_selected(path: String) -> void:
	selected_path = path
