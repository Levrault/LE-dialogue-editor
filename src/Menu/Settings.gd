extends MenuButton

enum Menu { locale, characters }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Locale", Menu.locale)

	get_popup().add_item("Characters", Menu.characters)
	if not Config.values.configuration.has_name and not Config.values.configuration.has_portrait:
		get_popup().set_item_disabled(Menu.characters, true)


func _on_Item_pressed(id: int) -> void:
	if id == Menu.locale:
		Events.emit_signal("locale_pop_up_displayed")
		return
	if id == Menu.characters:
		Events.emit_signal("characters_pop_up_displayed")
		return
