extends MenuButton

enum Menu { preview, folder_view }
var check_icon: Texture = preload("res://assets/icons/check.svg")


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Preview", Menu.preview)
	get_popup().add_item("Folder View", Menu.folder_view)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("preview"):
		Events.emit_signal("layout_preview_toggled")
		_set_icon(Menu.preview)
		return

	if event.is_action_pressed("folder_view"):
		Events.emit_signal("layout_folder_view_toggled")
		_set_icon(Menu.folder_view)
		return


func _on_Item_pressed(id: int) -> void:
	_set_icon(id)
	if id == Menu.folder_view:
		Events.emit_signal("layout_folder_view_toggled")
		return

	if id == Menu.preview:
		Events.emit_signal("layout_preview_toggled")
		return


func _set_icon(id: int) -> void:
	if get_popup().get_item_icon(id):
		get_popup().set_item_icon(id, null)
	else:
		get_popup().set_item_icon(id, check_icon)
