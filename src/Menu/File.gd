extends MenuButton

enum Menu { new, open, save, export_file, welcome_screen, quit }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("New Dialogue", Menu.new)
	get_popup().add_item("Open File", Menu.open)
	get_popup().add_item("Save", Menu.save)
	get_popup().add_item("Close Workspace", Menu.welcome_screen)
	get_popup().add_item("Quit", Menu.quit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_scene"):
		Editor.new_file()
		return
	if event.is_action_pressed("save_file"):
		Editor.save_file()
		return
	if event.is_action_pressed("open_file"):
		Editor.open_file()
		return


func _on_Item_pressed(id: int) -> void:
	if id == Menu.new:
		Editor.new_file()
		return

	if id == Menu.save:
		Editor.save_file()
		return

	if id == Menu.open:
		Editor.open_file()
		return

	if id == Menu.welcome_screen:
		Editor.load_welcome_screen()
		return

	if id == Menu.quit:
		get_tree().quit()
		return
