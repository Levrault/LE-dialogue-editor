# Singleton that manage values save
# How to create a new config interface
extends Node

const CONFIG_FILE_PATH := "user://config.cfg"
const DEFAULT_VALUES := {
	"locale":
	{
		"current": "en",
		"selected": ["en", "fr"],
		"custom": [{"locale": "fr_CA"}, {"locale": "js_PY", "language": "Javascript Python"}]
	},
	"variables":
	{
		"characters":
		[
			{
				"name": "Godot",
				"portraits":
				[
					{
						"uuid": "godot_default",
						"name": "Idle",
						"path": "res://icon.png",
						"default": true
					}
				]
			}
		],
	}
}

var _config_file := ConfigFile.new()
var values := DEFAULT_VALUES.duplicate(true)


# Find and load config.cfg file
# If not, create a new config file with default value
func _init() -> void:
	var err = _config_file.load(CONFIG_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found, create a new file with default values" % [CONFIG_FILE_PATH])
		self.save(DEFAULT_VALUES)
		self.load()
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [CONFIG_FILE_PATH, err])
		return
	self.load()


# Save data
# @param {Dictionary} new data - see DEFAULT_VALUES from struc
func save(new_settings: Dictionary) -> void:
	for section in new_settings.keys():
		for key in new_settings[section]:
			_config_file.set_value(section, key, new_settings[section][key])

	_config_file.save(CONFIG_FILE_PATH)


# Load data from config.cfg
func load() -> void:
	for section in values.keys():
		for key in values[section]:
			values[section][key] = _config_file.get_value(
				section, key, DEFAULT_VALUES[section][key]
			)

	print_debug("%s has been loaded" % [CONFIG_FILE_PATH])
