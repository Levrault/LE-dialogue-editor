extends MenuButton

enum Menu { new, open, save, save_as, quit }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")
	get_popup().add_item("New Scene", Menu.new)
	get_popup().add_item("Open File", Menu.open)
	get_popup().add_item("Save", Menu.save)
	get_popup().add_item("Save as", Menu.save_as)
	get_popup().add_item("Quit", Menu.quit)


func _on_Item_pressed(id: int) -> void:
	if id == Menu.save:
		Events.emit_signal("menu_popup_displayed", "SaveFileDialog")
		return

	if id == Menu.quit:
		get_tree().quit() 
		return
