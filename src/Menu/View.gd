extends MenuButton

enum Menu { preview, folder_view }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Preview", Menu.preview)
	get_popup().add_item("Folder View", Menu.folder_view)


func _unhandled_key_input(event: InputEvent) -> void:
	pass


func _on_Item_pressed(id: int) -> void:
	if id == Menu.folder_view:
		Events.emit_signal("layout_folder_view_toggled")
		return

	if id == Menu.preview:
		Events.emit_signal("layout_preview_toggled")
		return
