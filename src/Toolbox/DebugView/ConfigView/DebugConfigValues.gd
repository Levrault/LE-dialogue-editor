extends MarginContainer

onready var path := $Data/Path
onready var path_data := $Data/PathData
onready var configuration := $Data/Configuration
onready var configuration_data := $Data/ConfigurationData
onready var locale := $Data/Locale
onready var locale_data := $Data/LocaleData
onready var variables := $Data/Variables
onready var variables_data := $Data/VariablesData
onready var cache := $Data/Cache
onready var cache_data := $Data/CacheData
onready var info := $Data/Info
onready var info_data := $Data/InfoData


func _ready() -> void:
	path.connect("toggled", self, "_on_Toggled", [path_data])
	configuration.connect("toggled", self, "_on_Toggled", [configuration_data])
	locale.connect("toggled", self, "_on_Toggled", [locale_data])
	variables.connect("toggled", self, "_on_Toggled", [variables_data])
	cache.connect("toggled", self, "_on_Toggled", [cache_data])
	info.connect("toggled", self, "_on_Toggled", [info_data])


func _process(delta) -> void:
	path_data.text = JSON.print(Config.values.path, "\t")
	configuration_data.text = JSON.print(Config.values.configuration, "\t")
	locale_data.text = JSON.print(Config.values.locale, "\t")
	variables_data.text = JSON.print(Config.values.variables, "\t")
	cache_data.text = JSON.print(Config.values.cache, "\t")
	info_data.text = JSON.print(Config.values.info, "\t")


func _on_Toggled(button_pressed: bool, rich_text_label: RichTextLabel) -> void:
	rich_text_label.visible = button_pressed
