extends Node

signal cache_cleared

enum State {
	unregistred_pristine,  # 0: New file that hasn't been saved or changed
	unregistred_dirty,  # 1 :New file that has been changed
	registred_pristine,  # 2: Existing file that hasn't been saved or changed
	registred_dirty,  # 3: Existin file that has been changed
	exported  # 4: Export mode
}

const UNREGISTRED_NAME_TEMPLATE := "unregistred_%s.json"
var TEMP_PATH := "user://%s.%s"

var state = State.unregistred_pristine setget set_state
var previous_state = -1
var dirty_registred_files := {}
var dirty_unregistred_files := {}
var edited_file := {"path": ""} setget set_edited_file


func set_edited_file(values: Dictionary) -> void:
	edited_file = values

	if self.state == State.registred_pristine:
		Events.emit_signal("file_title_changed", values.name)
		return
	Events.emit_signal("file_title_changed", "%s *" % [values.name])


func set_state(new_state: int) -> void:
	previous_state = state
	state = new_state
	if new_state == State.registred_pristine:
		Events.emit_signal("file_title_changed", edited_file.name)
		return

	Events.emit_signal("file_title_changed", "%s *" % [edited_file.name])


func create_file() -> void:
	var new_file = UNREGISTRED_NAME_TEMPLATE % [dirty_unregistred_files.size()]
	var path = TEMP_PATH % [Editor.workspace.name, new_file]
	var value = {name = new_file, path = path, cache_path = path, unregistred = true}

	dirty_unregistred_files[path] = value
	edited_file = value

	self.state = State.unregistred_pristine

	Serialize.save_as(path, true, true)

	print_debug("%s has been cached inside %s" % [edited_file.path, Serialize.current_path])


func cache_file() -> void:
	if self.state != State.registred_dirty:
		return

	var path = TEMP_PATH % [Editor.workspace.name, edited_file.name]

	if not dirty_registred_files.has(edited_file.path):
		var values := {name = edited_file.name, cache_path = path, path = edited_file.path}
		edited_file.button_ref.values = values
		dirty_registred_files[edited_file.path] = values

	Serialize.save_as(path, true, true)


func dirty() -> void:
	if self.state == State.registred_pristine:
		self.state = State.registred_dirty
		var text := "%s *" % [edited_file.name]
		edited_file.button_ref.text = text
		return

	if self.state == State.unregistred_pristine:
		self.state = State.unregistred_dirty
		if not dirty_unregistred_files.has(edited_file.path):
			var values = edited_file.duplicate(true)
			if values.has("button_ref"):
				values.erase("button_ref")
			dirty_unregistred_files[edited_file.path] = values


func pristine() -> void:
	edited_file.button_ref.text = edited_file.name
	delete_cache(edited_file.path)
	edited_file.button_ref.values.erase("cache_path")
	edited_file.button_ref.values.erase("unregistred")

	if self.state == State.registred_dirty:
		self.state = State.registred_pristine
		return

	self.state = State.registred_pristine


func is_file_dirty(file_path: String) -> bool:
	return dirty_registred_files.has(file_path) or dirty_unregistred_files.has(file_path)


func should_be_registred() -> bool:
	return self.state == State.unregistred_pristine or self.state == State.unregistred_dirty


func should_be_cached() -> bool:
	return self.state == State.unregistred_dirty


# When clicking on the workspace view and deleting a file
# it wills call this function. It wills clean the cache, update
# the config if the file was registred and load the last opened file or and new
# empty file if needed
# @param {Dictionary} file_to_delete
func delete_file(file_to_delete: Dictionary, delete_from_disk: bool) -> void:
	# delete from cache
	if file_to_delete.has("unregistred"):
		delete_cache(file_to_delete.cache_path)
	else:
		# If existing file, delete from disk
		delete_cache(file_to_delete.path)

		if delete_from_disk:
			var dir = Directory.new()
			dir.remove(file_to_delete.path)

		# Workspace file: Delete from files list
		for file in Config.values.variables.files:
			if file.path == file_to_delete.path:
				Config.values.variables.files.erase(file)

		# Set last opened file
		if Config.values.variables.files.empty():
			Config.values.cache.last_opened_file = {}
		else:
			var last_file: Dictionary = Config.values.variables.files[(
				Config.values.variables.files.size()
				- 1
			)]
			Config.values.cache.last_opened_file = {name = last_file.name, path = last_file.path}

		Config.save(Config.values, Editor.workspace.folder)

	# in reset mode
	if file_to_delete.path == edited_file.path:
		Editor.reset()
		yield(Editor, "scene_cleared")

		if not Config.values.cache.last_opened_file.empty():
			Serialize.load(Config.values.cache.last_opened_file.path)
			self.edited_file = Config.values.cache.last_opened_file.duplicate(true)
			self.state = State.registred_pristine
			Events.call_deferred("emit_signal", "workspace_files_updated")
		else:
			Editor.load_last_opened_file = false
			Events.emit_signal("workspace_unsaved_file_added")
			self.state = State.unregistred_pristine


func delete_cache(path: String) -> void:
	var dir = Directory.new()

	for key in dirty_unregistred_files:
		if dirty_unregistred_files[key].path == path:
			dir.remove(dirty_unregistred_files[key].cache_path)
			dirty_unregistred_files.erase(key)
			return

	for key in dirty_registred_files:
		if dirty_registred_files[key].path == path:
			dir.remove(dirty_registred_files[key].cache_path)
			dirty_registred_files.erase(key)
			return


func clear() -> void:
	var dir = Directory.new()

	for key in dirty_unregistred_files:
		dir.remove(dirty_unregistred_files[key].cache_path)
	dirty_registred_files.clear()

	for key in dirty_registred_files:
		dir.remove(dirty_registred_files[key].cache_path)
	dirty_unregistred_files.clear()

	emit_signal("cache_cleared")
