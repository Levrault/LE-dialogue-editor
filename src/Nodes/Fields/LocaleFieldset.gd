extends VBoxContainer

var initial_text = ""
onready var locale := $Locale
onready var label := $Label


func _ready() -> void:
	Events.connect("locale_changed", self, "_on_Localization_changed")
	Events.connect("file_loaded", self, "_on_File_loaded")
	locale.connect("text_changed", self, "_on_Text_changed")

	initial_text = label.text
	label.text = "%s (%s)" % [initial_text, Editor.locale]


func _on_Text_changed() -> void:
	owner.values.text[Editor.locale] = locale.text


func _on_Localization_changed(new_lang: String) -> void:
	locale.text = owner.values.text[Editor.locale]
	label.text = "%s (%s)" % [initial_text, new_lang]


func _on_File_loaded() -> void:
	locale.text = owner.values.text[Editor.locale]
