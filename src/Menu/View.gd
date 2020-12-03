extends MenuButton

enum Menu { preview, workspace_view }
var check_icon: Texture = preload("res://assets/icons/check.svg")


func _ready():
	Events.connect("layout_workspace_view_closed", self, "_set_icon", [Menu.workspace_view])
	Events.connect("layout_preview_closed", self, "_set_icon", [Menu.preview])
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Preview", Menu.preview)
	if Config.globals.views.preview:
		_set_icon(Menu.preview)

	get_popup().add_item("Workspace", Menu.workspace_view)
	if Config.globals.views.workspace:
		_set_icon(Menu.workspace_view)


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("preview"):
		Events.emit_signal("layout_preview_toggled")
		_set_icon(Menu.preview)
		return

	if event.is_action_pressed("workspace_view"):
		Events.emit_signal("layout_workspace_view_toggled")
		_set_icon(Menu.workspace_view)
		return


func _on_Item_pressed(id: int) -> void:
	_set_icon(id)
	if id == Menu.workspace_view:
		Events.emit_signal("layout_workspace_view_toggled")
		return

	if id == Menu.preview:
		Events.emit_signal("layout_preview_toggled")
		return


func _set_icon(id: int) -> void:
	if get_popup().get_item_icon(id):
		get_popup().set_item_icon(id, null)
	else:
		get_popup().set_item_icon(id, check_icon)
