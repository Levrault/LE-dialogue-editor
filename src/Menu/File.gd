extends MenuButton

const SAVE := "Save"


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")
	get_popup().add_item("New")
	get_popup().add_item("Open")
	get_popup().add_item(SAVE)
	get_popup().add_item("Quit")


func _on_Item_pressed(id: int) -> void:

	var action := get_popup().get_item_text(id)
	if action == SAVE:
		Events.emit_signal("menu_popup_displayed", "SaveFileDialog")

