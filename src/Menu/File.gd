extends MenuButton

enum Menu { new, open, save, save_as, quit }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("New Scene", Menu.new)
	get_popup().add_item("Open File", Menu.open)
	get_popup().add_item("Save", Menu.save)
	get_popup().add_item("Save as", Menu.save_as)
	get_popup().add_item("Quit", Menu.quit)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_file"):
		Editor.save_file()
		return
	if event.is_action_pressed("open_file"):
		Editor.open_file()
		return


func _on_Item_pressed(id: int) -> void:
	if id == Menu.save:
		Editor.save_file()
		return

	if id == Menu.open:
		Editor.open_file()
		return

	if id == Menu.quit:
		get_tree().quit()
		return
