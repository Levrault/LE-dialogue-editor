# Create the preview of the character portrait
extends HBoxContainer
const PREVIEW_IMG_SIZE := Vector2(92, 92)

var imported_portrait_item_scene := preload("res://src/Popup/Characters/ImportedPortraitItem.tscn")


func clean() -> void:
	for child in get_children():
		child.queue_free()


func add_item(portrait: Dictionary, is_edit_mode := false) -> void:
	var imported_portrait_item := imported_portrait_item_scene.instance()
	add_child(imported_portrait_item)
	imported_portrait_item.portrait.texture = Editor.import_image(portrait.path, PREVIEW_IMG_SIZE)
	imported_portrait_item.portrait_name.text = portrait.name
	imported_portrait_item.default.pressed = true if portrait.has("default") else false

	# values to stock
	imported_portrait_item.values = portrait

	if not is_edit_mode:
		owner.form_values.portraits.append(portrait)


func change_default_portrait(ref: VBoxContainer) -> void:
	for child in get_children():
		if child == ref:
			continue
		if not child.default.pressed:
			continue
		child.default.pressed = false
