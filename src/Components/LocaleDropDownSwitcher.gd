extends Control

var animated_button_scene := preload("res://src/Components/AnimatedToolButton.tscn")
var is_open := false
var current_locale: String = Config.values.locale.current setget set_current_locale
var previous_locale: String = current_locale

onready var anim := $AnimationPlayer
onready var switcher := $Switcher
onready var drop_down_button := $DropDown
onready var locale_container := $ScrollContainer/PanelContainer/LocaleContainer


func _ready() -> void:
	Events.connect("i18n_changed", self, "_on_I18n_changed")
	switcher.connect("pressed", self, "_on_Switcher_pressed")
	drop_down_button.connect("focus_exited", self, "_on_Dropdown_focus_exited")
	drop_down_button.connect("pressed", self, "_on_Dropdown_pressed")

	anim.play("DEFAULT")

	_on_I18n_changed()

	# set default locale
	switcher.text = current_locale


func set_current_locale(value: String) -> void:
	if current_locale == value:
		return
	previous_locale = current_locale
	current_locale = value
	switcher.text = value
	Editor.locale = current_locale


func _on_Switcher_pressed() -> void:
	if previous_locale == current_locale:
		return
	var temp_locale := current_locale
	current_locale = previous_locale
	previous_locale = temp_locale
	switcher.text = current_locale
	Editor.locale = current_locale


func _on_Dropdown_pressed() -> void:
	if is_open:
		is_open = false
		anim.play("close")
		return
	is_open = true
	anim.play("open")


func _on_Dropdown_focus_exited() -> void:
	is_open = false
	anim.play("close")


func _on_Locale_pressed(locale: String) -> void:
	if current_locale == locale:
		return
	self.current_locale = locale


func _on_I18n_changed() -> void:
	for child in locale_container.get_children():
		locale_container.remove_child(child)
		child.queue_free()

	var editor_locale_enabled := false
	for locale in Config.values.locale.selected:
		var button := animated_button_scene.instance()
		button.text = locale
		button.name = locale
		button.align = ToolButton.ALIGN_LEFT
		button.connect("pressed", self, "_on_Locale_pressed", [locale])
		locale_container.add_child(button)

	if not Config.values.locale.selected.has(Editor.locale):
		Editor.locale = Config.values.locale.selected[0]
		self.current_locale = Editor.locale
