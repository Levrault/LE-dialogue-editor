extends Node

var current_path := ''


func save_as(path: String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(Json.to_string())
	file.close()
	current_path = path
	Editor.current_state = Editor.FileState.saved


func save() -> void:
	var file = File.new()
	file.open(current_path, File.WRITE)
	file.store_string(Json.to_string())
	file.close()
	Editor.current_state = Editor.FileState.saved


func load(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	Editor.current_state = Editor.FileState.saved
	return content
