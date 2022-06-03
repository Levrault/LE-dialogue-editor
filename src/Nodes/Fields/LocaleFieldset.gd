extends VBoxContainer

var ZH_FONT = preload("res://assets/fonts/Noto_Sans_SC/NotoSansSC-Regular.otf")
var LATIN_FONT = preload("res://assets/fonts/droid-sans/DroidSans.ttf")

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
	owner.values.data.text[Editor.locale] = locale.text


func _on_Localization_changed(new_lang: String) -> void:
	if not owner.values.data.text.has(Editor.locale):
		owner.values.data.text[Editor.locale] = ""

	locale.text = owner.values.data.text[Editor.locale]
	label.text = "%s (%s)" % [initial_text, new_lang]


	# specific fonts locale (if your language is not supported, please open a PR)
	# chinese
#	var dynamic_font = DynamicFont.new()
#	if new_lang == "zh":
#		dynamic_font.font_data = ZH_FONT
#	else:
#		dynamic_font.font_data = LATIN_FONT
#	dynamic_font.size = 14
#	locale.set("custom_fonts/font", dynamic_font)


func _on_File_loaded() -> void:
	locale.text = owner.values.data.text[Editor.locale]
	locale.emit_signal("text_changed")
