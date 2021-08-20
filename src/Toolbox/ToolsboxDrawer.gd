extends Control

enum View { preview, json, locale, characters, debug }

var current_view := -1

onready var close_button := $MarginContainer/Container/Header/CloseButton
onready var view_container := $MarginContainer/Container
onready var header := $MarginContainer/Container/Header
onready var title := $MarginContainer/Container/Header/Title
onready var preview_view := $MarginContainer/Container/PreviewView
onready var json := $MarginContainer/Container/Json
onready var debug := $MarginContainer/Container/DebugView


func _ready() -> void:
	Events.connect("toolbox_preview_button_pressed", self, "_on_View_updated", [View.preview])
	Events.connect("toolbox_json_button_pressed", self, "_on_View_updated", [View.json])
	Events.connect("toolbox_locale_button_pressed", self, "_on_View_updated", [View.locale])
	Events.connect("toolbox_characters_button_pressed", self, "_on_View_updated", [View.characters])
	Events.connect("debug_button_pressed", self, "_on_View_updated", [View.debug])
	close_button.connect("pressed", self, "hide")

	if Config.globals.views.preview:
		_show_preview()

	if Config.globals.views.json:
		_show_json()


func _on_View_updated(view) -> void:
	if current_view == view:
		current_view = -1
		hide()
		return
	show()
	
	for child in view_container.get_children():
		child.hide()
	header.show()
	var should_update_config := false
	Config.globals.views.preview = false
	Config.globals.views.json = false

	if view == View.preview:
		should_update_config = true
		_show_preview()
		Config.globals.views.preview = true

	if view == View.json:
		should_update_config = true
		_show_json()
		Config.globals.views.json = true

	if view == View.debug:
		_show_debug()

	if should_update_config:
		Config.save(Config.globals)


func _show_preview() -> void:
	current_view = View.preview
	title.text = "Preview"
	preview_view.show()


func _show_json() -> void:
	current_view = View.json
	title.text = "Json"
	json.show()


func _show_debug() -> void:
	current_view = View.debug
	title.text = "Debug"
	debug.show()
