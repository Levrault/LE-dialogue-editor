extends VBoxContainer

enum View {menu, config, editor, file}


func _ready():
	hide()
	Events.connect("debug_view_displayed", self, "_on_View_updated", [View.menu])
	$MenuContainer/ConfigButton.connect("pressed", self, "_on_View_updated", [View.config])
	$MenuContainer/EditorButton.connect("pressed", self, "_on_View_updated", [View.editor])
	$MenuContainer/FileButton.connect("pressed", self, "_on_View_updated", [View.file])

	for child in get_children():
		child.hide()

	$MenuContainer.show()


func _on_View_updated(view) -> void:
	for child in get_children():
		child.hide()

	if view == View.menu:
		$MenuContainer.show()
		return

	if view == View.config:
		$DebugConfigView.show()
		return

	if view == View.editor:
		$DebugEditorView.show()
		return

	if view == View.file:
		$DebugFileView.show()
		return


