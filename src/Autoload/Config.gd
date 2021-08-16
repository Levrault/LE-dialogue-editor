# Singleton that manage values to be saved
# Should keep the list of workspaces
# Manage data per workspaces
extends Node

const GLOBAL_CONFIG_FILE_PATH := "user://config.cfg"
const DEFAULT_VALUES := {
	"path":
	{
		"resource": "",
		"OSX": "",
		"Windows": "",
		"UWP": "",
		"X11": "",
	},
	"configuration":
	{
		"has_portrait": true,
		"has_name": true,
		"dialogue_character_limit": 0,
		"choice_character_limit": 0
	},
	"locale": {"current": "en", "selected": ["en", "fr"], "custom": []},
	"variables": {"characters": [{"name": "Godot", "portraits": []}], "files": []},
	"cache": {"last_opened_file": {}},
	"info": {"version": "", "window_height": 1920, "window_width": 1080, "full_screen": false},
}

const DEFAULT_GLOBALS := {
	"workspaces": {"list": []},
	"views": {"preview": false, "json": false, "workspace": true},
	"info": {"version": ""}
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
		globals["info"]["version"] = ProjectSettings.get_setting("Info/version")
		self.save(globals)
		self.load(globals)
		return
	if err != OK:
		print_debug("%s has encounter an error: %s" % [GLOBAL_CONFIG_FILE_PATH, err])
		return
	self.load(globals)
	sync_workspace_list_to_existing_file(globals)
	update_editor_config_if_needed(globals)


# load workspace file only
# @param {String} path
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
	update_workspace_file_if_needed(values, path)


# Load data from config.cfg
# @param {Dictionary}	new_settings
# @param {Dictionary}	[template=DEFAULT_GLOBALS] - default template struc
func load(settings: Dictionary, template := DEFAULT_GLOBALS) -> void:
	for section in settings.keys():
		for key in settings[section]:
			settings[section][key] = _config_file.get_value(section, key, template[section][key])

	print_debug("%s has been loaded" % [GLOBAL_CONFIG_FILE_PATH])


# Save data
# @see load_file and _init
# @param {Dictionary}	new_settings - values or global of this file
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


# Create a new workspace while updating the global config
# @param {Dictionary}	new_settings
# @param {Dictionary}	path - where to save
func new_workspace(new_settings: Dictionary, path: String) -> void:
	# add workspace to global config
	globals.workspaces.list.append(new_settings.path)
	save(globals)

	# save workspace
	new_settings["info"] = {}
	new_settings["info"]["version"] = ProjectSettings.get_setting("Info/version")
	save(new_settings, path)
	self.load(values, DEFAULT_VALUES)


func read_workspace_file(path: String):
	var file := ConfigFile.new()
	var err = file.load(path)

	if err == ERR_FILE_NOT_FOUND:
		print_debug("%s was not found when loadding workspace data" % [path])
		return ""
	if err != OK:
		print_debug("%s has encounter an error when loadding workspace data" % [path])
		return ""

	return file


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


# check if a file has been deleted, if yes, clean the config file
func sync_workspace_list_to_existing_file(loaded_settings) -> void:
	var file := File.new()
	for workspace in loaded_settings.workspaces.list:
		if file.file_exists(workspace.folder):
			continue
		loaded_settings.workspaces.list.erase(workspace)

	self.save(loaded_settings)


# Called everytime a workspace is loaded to be sure
# his structure is up to date
# @param {Dictionary) loaded_settings - data of the workspace file
# @param {String} path - file path to save it after update
func update_workspace_file_if_needed(loaded_settings: Dictionary, path: String) -> void:
	var has_been_updated := false

	# from 1.0.0-beta to 1.0.3-beta
	if (
		not loaded_settings.has("info")
		or loaded_settings.info.version.empty()
		or loaded_settings.path.has("resource")
		or loaded_settings.path.has("path")
	):
		UpdateTool.migrate_workspace_v1_x_x_to_v1_0_3_beta(loaded_settings, DEFAULT_VALUES)
		has_been_updated = true
		print_debug("%s workspace file has been update to 1.0.3-beta" % path)

	if not has_been_updated:
		print_debug("%s is synched with the latest file structure " % path)
		return
	self.save(loaded_settings, path)


# Called everytime LE-dialogue-editor is opened to update his config file if needed
# @param {Dictionary) loaded_settings - data of the workspace file
# @param {String} path - file path to save it after update
func update_editor_config_if_needed(loaded_settings: Dictionary) -> void:
	var has_been_updated := false

	# from 1.0.0-beta to 1.0.3-beta
	if not loaded_settings.has("info") or loaded_settings.info.version.empty():
		UpdateTool.migrate_editor_config_v1_x_x_to_v1_0_3_beta(loaded_settings, DEFAULT_GLOBALS)
		has_been_updated = true
		print_debug("Editor file has been update to 1.0.3-beta")

	if loaded_settings.info.version == "v1.0.3-beta":
		UpdateTool.migrate_to_last_version_only(loaded_settings)
		has_been_updated = true

	if not has_been_updated:
		print_debug("Editor file is synched with the latest file structure ")
		return
	self.save(loaded_settings)
