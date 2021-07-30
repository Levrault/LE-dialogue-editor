extends MenuButton

enum Menu { wiki, github, twitter, about }


func _ready():
	get_popup().connect("id_pressed", self, "_on_Item_pressed")

	# add items
	get_popup().add_item("Wiki", Menu.wiki)
	get_popup().add_item("Github", Menu.github)
	get_popup().add_item("Twitter", Menu.twitter)
	get_popup().add_item("About", Menu.about)


func _on_Item_pressed(id: int) -> void:
	if id == Menu.wiki:
		OS.shell_open(ProjectSettings.get_setting("Info/wiki"))
		return
	if id == Menu.github:
		OS.shell_open(ProjectSettings.get_setting("Info/github"))
		return
	if id == Menu.twitter:
		OS.shell_open(ProjectSettings.get_setting("Info/twitter"))
		return
	if id == Menu.about:
		Events.emit_signal("about_pop_up_displayed")
		return
