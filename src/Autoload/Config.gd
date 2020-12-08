# Singleton that manage values to be saved
# Should keep the list of workspaces
# Manage data per workspaces
extends Node

const GLOBAL_CONFIG_FILE_PATH := "user://config.cfg"
const DEFAULT_VALUES := {
	"path":
	{
		"file": "",
		"resource": "",
	},
	"locale": {"current": "en", "selected": ["en", "fr"], "custom": []},
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
		"files": []
	},
	"cache": {"last_opened_file": {}}
}

const DEFAULT_GLOBALS := {
	"workspaces": {"list": []}, "views": {"preview": false, "workspace": true}
}

var _config_file := ConfigFile.new()
var values := DEFAULT_VALUES.duplicate(true)
var globals := DEFAULT_GLOBALS.duplicate(true)


# Find and load config.cfg file
# If not, create a new config file with default value
func _init() -> void:
	var err = _config_file.load(GLOBAL_CONFIG_FILE_PATH)
	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found, default globals added" % [GLOBAL_CONFIG_FILE_PATH])
		self.save(DEFAULT_GLOBALS)
		self.load(globals)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [GLOBAL_CONFIG_FILE_PATH, err])
		return
	self.load(globals)


func load_file(path: String) -> void:
	for section in _config_file.get_sections():
		_config_file.erase_section(section)

	var err = _config_file.load(path)
	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found, create a new file with default values" % [path])
		self.save(DEFAULT_VALUES)
		self.load(values, DEFAULT_VALUES)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [path, err])
		return
	self.load(values, DEFAULT_VALUES)


# Create a new workspace while updating the global config
# @param {Dictionary}	new_settings 
# @param {Dictionary}	path - where to save
func new_workspace(new_settings: Dictionary, path: String) -> void:
	# add workspace to global config
	globals.workspaces.list.append(new_settings.path)
	save(globals)

	# save workspace
	save(new_settings, path)
	self.load(values, DEFAULT_VALUES)


func get_workspace_resource(path: String) -> String:
	var file := ConfigFile.new()
	var err = file.load(path)

	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found when loadding workspace data" % [path])
		return ""
	if err != OK:
		print_debug("%s has encounter an error when loadding workspace data" % [path])
		return ""

	return file.get_value("path", "resource")


# Save data
# @param {Dictionary}	new_settings 
# @param {Dictionary}	[path=GLOBAL_CONFIG_FILE_PATH] - where to save
func save(new_settings: Dictionary, path := GLOBAL_CONFIG_FILE_PATH) -> void:
	# clean file
	for section in _config_file.get_sections():
		_config_file.erase_section(section)

	for section in new_settings.keys():
		for key in new_settings[section]:
			_config_file.set_value(section, key, new_settings[section][key])

	print_debug("%s has been saved" % [path])
	_config_file.save(path)


# Load data from config.cfg
# @param {Dictionary}	new_settings 
# @param {Dictionary}	[template=DEFAULT_GLOBALS] - default template struc
func load(settings: Dictionary, template := DEFAULT_GLOBALS) -> void:
	for section in settings.keys():
		for key in settings[section]:
			settings[section][key] = _config_file.get_value(section, key, template[section][key])

	print_debug("%s has been loaded" % [GLOBAL_CONFIG_FILE_PATH])


func has_file_path(path: String) -> bool:
	for file in values.variables.files:
		if file.path == path:
			return true
	return false


func get_character(name: String) -> Dictionary:
	var character := {}
	for c in values.variables.characters:
		if c.name == name:
			character = c
			break

	return character
