extends MenuButton

enum Menu { new, open, workspace, save, export_file, quit }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("New Dialogue", Menu.new)
	get_popup().add_item("Open File", Menu.open)
	get_popup().add_item("Save", Menu.save)
	get_popup().add_item("Export", Menu.export_file)
	get_popup().add_item("Workspaces List", Menu.workspace)
	get_popup().add_item("Quit", Menu.quit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_scene"):
		if Editor.current_state == Editor.FileState.unsaved:
			Events.emit_signal("unsaved_file_displayed")
			return
		Editor.new_file()
		return
	if event.is_action_pressed("save_file"):
		Editor.save_file()
		return
	if event.is_action_pressed("export_file"):
		Editor.current_state = Editor.FileState.export_file
		Editor.save_file()
		return
	if event.is_action_pressed("open_file"):
		Editor.open_file()
		return


func _on_Item_pressed(id: int) -> void:
	if id == Menu.new:
		if Editor.current_state == Editor.FileState.unsaved:
			Events.emit_signal("unsaved_file_displayed")
			return
		Editor.new_file()
		return

	if id == Menu.save:
		Editor.save_file()
		return

	if id == Menu.open:
		if Editor.current_state == Editor.FileState.unsaved:
			Editor.current_state = Editor.FileState.opened
			Events.emit_signal("unsaved_file_displayed")
			return
		Editor.open_file()
		return

	if id == Menu.workspace:
		Editor.open_workspace()
		return

	if id == Menu.export_file:
		Editor.current_state = Editor.FileState.export_file
		Editor.save_file()
		return

	if id == Menu.quit:
		get_tree().quit()
		return
