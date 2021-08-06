extends FileDialog
class_name WorkspaceFormDialog

var field = null
var selected_path := ""

export var connected_signal := ""


func _ready() -> void:
	Events.connect(connected_signal, self, "_on_Show")
	connect("dir_selected", self, "_on_Dir_selected")
	connect("confirmed", self, "_on_Confirmed")


func _on_Show(node) -> void:
	popup()
	field = node


func _on_Confirmed() -> void:
	if selected_path.empty():
		selected_path = current_dir
	field.value = selected_path


func _on_Dir_selected(path: String) -> void:
	selected_path = path
