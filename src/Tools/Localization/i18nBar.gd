extends Control

const TRIGGER_SWITCH := 3

var locale_button_scene := preload("res://src/Components/LocaleButton.tscn")

onready var container := $Container
onready var locale_drop_down_switcher := $LocaleDropDownSwitcher


func _ready() -> void:
	Events.connect("i18n_changed", self, "_on_I18n_changed")
	_on_I18n_changed()


func _on_Pressed(selected_child: String) -> void:
	for child in container.get_children():
		child.pressed = false
	container.get_node(selected_child).pressed = true


func _on_I18n_changed() -> void:
	# switcher
	if Config.values.locale.selected.size() >= TRIGGER_SWITCH:
		container.hide()
		locale_drop_down_switcher.current_locale = Editor.locale
		locale_drop_down_switcher.show()
		return

	# clean previous button 
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for locale in Config.values.locale.selected:
		var button := locale_button_scene.instance()
		button.text = locale
		button.name = locale
		button.connect("pressed", self, "_on_Pressed", [locale])
		if button.text == Editor.locale:
			button.pressed = true
		container.add_child(button)

	# check if the editor locale's no more present in the list
	if not Config.values.locale.selected.has(Editor.locale):
		Editor.locale = Config.values.locale.selected[0]
		container.get_node(Editor.locale).pressed = true

	container.show()
	locale_drop_down_switcher.hide()
