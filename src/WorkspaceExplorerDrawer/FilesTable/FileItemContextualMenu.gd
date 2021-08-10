extends AnimatedMenuButton

enum Menu { remove, delete }
var file_minus_svg: Texture = load("res://assets/icons/file-minus.svg")
var trash_svg: Texture = load("res://assets/icons/trash.svg")


func _ready() -> void:
	yield(owner, "ready")

	# hide menu to prevent deletion on the only unregistred file
	_on_Files_updated()

	Events.connect("workspace_files_updated", self, "_on_Files_updated")
	connect("toggled", self, "_on_Toggled")
	get_popup().connect("id_pressed", self, "_on_Item_pressed")


func _on_Files_updated() -> void:
	if (
		not Config.values.variables.files.empty()
		or not FileManager.dirty_unregistred_files.size() <= 1
	):
		return
	queue_free()


func _on_Values_changed() -> void:
	if not owner.button.values.has("unregistred"):
		get_popup().add_icon_item(file_minus_svg, "Remove from workspace", Menu.remove)
	get_popup().add_icon_item(trash_svg, "Delete file from disk", Menu.delete)


func _on_Toggled(pressed: bool) -> void:
	self.selected = pressed
	if pressed:
		.rotate(90)
		return
	.rotate(0)


func _on_Item_pressed(id: int) -> void:
	print(owner.button.values)
	if id == Menu.remove:
		FileManager.delete_file(owner.button.values, false)
		owner.queue_free()
		return
	if id == Menu.delete:
		FileManager.delete_file(owner.button.values, true)
		owner.queue_free()
		return
