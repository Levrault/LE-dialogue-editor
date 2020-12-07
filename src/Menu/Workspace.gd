extends MenuButton

enum Menu { Delete }

var trash_icon: Texture = preload("res://assets/icons/trash.svg")


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Delete this workspace", Menu.Delete)
	get_popup().set_item_icon(Menu.Delete, trash_icon)


func _on_Item_pressed(id: int) -> void:
	if id == Menu.Delete:
		for workspace in Config.globals.workspaces.list:
			if Editor.workspace == workspace:
				Config.globals.workspaces.list.erase(workspace)
				break

		Config.save(Config.globals)
		Editor.load_welcome_screen()
		return
