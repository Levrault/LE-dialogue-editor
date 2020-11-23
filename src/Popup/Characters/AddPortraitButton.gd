# Open file dialog to select a new portrait
extends AnimatedToolButton

# workaroundd since godot's doubleclick behavior doesn't call confirmed
var is_confirmed_called := false
var is_selected_called := false


func _ready() -> void:
	yield(owner, "ready")
	connect("pressed", self, "_on_Pressed")
	owner.portrait_file_dialog.connect("confirmed", self, "_on_File_confirmed")
	owner.portrait_file_dialog.connect("file_selected", self, "_on_File_selected")


func _on_Pressed() -> void:
	is_selected_called = false
	is_confirmed_called = false
	owner.portrait_file_dialog.popup()


func _on_File_confirmed() -> void:
	is_confirmed_called = true

	owner.import_container.add_item(
		{
			uuid = Uuid.v4(),
			name = owner.portrait_file_dialog.current_file,
			path = owner.portrait_file_dialog.current_path.replace(
				Editor.workspace.resource, Constant.RESOURCE
			)
		}
	)


func _on_File_selected(file_selected: String) -> void:
	is_selected_called = true

	if not is_confirmed_called:
		_on_File_confirmed()
