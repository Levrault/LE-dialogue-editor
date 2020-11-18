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
var edited_file := {"path": ""}


func set_state(new_state: int) -> void:
	previous_state = state
	state = new_state


func create_file() -> void:
	var new_file = UNREGISTRED_NAME_TEMPLATE % [dirty_unregistred_files.size()]
	var path = TEMP_PATH % [Editor.workspace.name, new_file]
	var value = {name = new_file, path = path, cache_path = path, unregistred = true}

	FileManager.state = FileManager.State.unregistred_pristine

	dirty_unregistred_files[path] = value
	edited_file = value

	Serialize.save_as(path, true, true)

	print_debug("%s has been cached inside %s" % [edited_file.path, Serialize.current_path])


func cache_file() -> void:
	if state != State.registred_dirty:
		return

	var path = TEMP_PATH % [Editor.workspace.name, edited_file.name]

	if not dirty_registred_files.has(edited_file.path):
		var values := {name = edited_file.name, cache_path = path, path = edited_file.path}
		edited_file.button_ref.values = values
		dirty_registred_files[edited_file.path] = values

	Serialize.save_as(path, true, true)


func dirty() -> void:
	if state == State.registred_pristine:
		state = State.registred_dirty
		edited_file.button_ref.text = "%s *" % [edited_file.name]

		return

	if state == State.unregistred_pristine:
		state = State.unregistred_dirty
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

	if state == State.registred_dirty:
		state = State.registred_pristine
		return

	state = State.registred_pristine


func is_file_dirty(file_path: String) -> bool:
	return dirty_registred_files.has(file_path) or dirty_unregistred_files.has(file_path)


func should_be_registred() -> bool:
	return state == State.unregistred_pristine or state == State.unregistred_dirty


func should_be_cached() -> bool:
	return state == State.unregistred_dirty


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

	for key in dirty_registred_files:
		dir.remove(dirty_registred_files[key].cache_path)

	emit_signal("cache_cleared")
