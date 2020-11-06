extends WindowDialog

var label_scene := preload("res://src/Components/Label.tscn")
var checkbox_scene := preload("res://src/Components/Checkbox.tscn")
var selected_locale_list_code := []

onready var locale_list := $MarginContainer/VBoxContainer/HBoxContainer/LocaleList/VBoxContainer
onready var selected_locale_list := $MarginContainer/VBoxContainer/HBoxContainer/SelectedLocaleList/VBoxContainer
onready var create_locale_button := $MarginContainer/VBoxContainer/FormContainer/ButtonContainer/CreateLocaleButton
onready var locale_line_edit := $MarginContainer/VBoxContainer/FormContainer/FieldContainer/LocaleContainer/LocaleLineEdit
onready var language_line_edit := $MarginContainer/VBoxContainer/FormContainer/FieldContainer/LanguageContainer/LanguageLineEdit


func _ready() -> void:
	Events.connect("locale_pop_up_displayed", self, "_on_Locale_pop_up_displayed")
	create_locale_button.connect("pressed", self, "_on_Create_locale_pressed")
	get_close_button().connect("pressed", self, "_on_Close_pressed")

	for checkbox in locale_list.get_children():
		checkbox.connect("toggled", self, "_on_Checkbox_toggled", [checkbox.text])
		if Config.values.locale.selected.has(checkbox.text):
			checkbox.pressed = true
		checkbox.text = _get_locale_text(checkbox.text)
	for custom_locale in Config.values.locale.custom:
		_create_custom_locale_checkbox(custom_locale)


func _on_Locale_pop_up_displayed() -> void:
	popup()


func _on_Close_pressed() -> void:
	Config.save(Config.values, Editor.project.project)


func _on_Checkbox_toggled(button_pressed: bool, value: String) -> void:
	if not button_pressed:
		# can't allow 0 locale
		if Config.values.locale.selected.size() == 1:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.warning,
				"WARNING: you must set, at least, one locale"
			)

			# hack to keep the button pressed
			locale_list.get_node(value).disconnect("toggled", self, "_on_Checkbox_toggled")
			locale_list.get_node(value).pressed = true
			locale_list.get_node(value).connect("toggled", self, "_on_Checkbox_toggled", [value])
			return

		# remove locale
		selected_locale_list_code.erase(value)
		selected_locale_list.get_node(value).queue_free()
		Config.values.locale.selected.erase(value)
		Events.emit_signal("i18n_changed")

		# clean locale on text file
		Store.remove_locale(value)

		return

	# prevent duplicate on load
	if not Config.values.locale.selected.has(value):
		Config.values.locale.selected.append(value)

	# add locale
	selected_locale_list_code.append(value)
	var label := label_scene.instance()
	label.name = value
	label.text = _get_locale_text(value)
	selected_locale_list.add_child(label)
	Events.emit_signal("i18n_changed")


func _on_Create_locale_pressed() -> void:
	var code: String = locale_line_edit.text
	var language: String = language_line_edit.text
	var result := {}

	if code.empty():
		Events.emit_signal(
			"notification_displayed", Editor.Notification.error, "ERROR: locale is mandatory"
		)
		return

	if Config.values.locale.custom.has(code):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"ERROR: locale %s is already defined" % [code]
		)
		return

	for custom_locale in Config.values.locale.custom:
		if custom_locale.locale == code:
			Events.emit_signal(
				"notification_displayed",
				Editor.Notification.error,
				"ERROR: locale %s is already defined" % [code]
			)
			return

	result["locale"] = code

	if not language.empty():
		result["language"] = language

	Config.values.locale.custom.append(result)
	_create_custom_locale_checkbox(result)
	locale_line_edit.text = ""
	language_line_edit.text = ""


func _get_locale_text(code: String) -> String:
	if not TranslationServer.get_locale_name(code):
		return code
	return "%s (%s)" % [TranslationServer.get_locale_name(code), code]


func _create_custom_locale_checkbox(custom_locale: Dictionary) -> void:
	var checkbox = checkbox_scene.instance()
	checkbox.name = custom_locale.locale
	checkbox.connect("toggled", self, "_on_Checkbox_toggled", [custom_locale.locale])
	if Config.values.locale.selected.has(custom_locale.locale):
		checkbox.pressed = true
	if not custom_locale.has("language"):
		checkbox.text = _get_locale_text(custom_locale.locale)
	else:
		checkbox.text = "%s (%s)" % [custom_locale.language, custom_locale.locale]
	locale_list.add_child(checkbox)
