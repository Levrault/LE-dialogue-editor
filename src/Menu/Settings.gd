extends MenuButton

enum Menu { locale }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Locale", Menu.locale)


func _on_Item_pressed(id: int) -> void:
	if id == Menu.locale:
		Events.emit_signal("locale_pop_up_displayed")
		return
