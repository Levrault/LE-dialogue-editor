extends Node

enum Type { start, dialogue, choice, condition, signal_node }
enum FileState { new, opened, unsaved, saved }

var current_state = FileState.new

var locale := 'en' setget set_locale


func type_to_string(value: int) -> String:
	var result := ''
	match value:
		Type.start:
			result = 'start'
		Type.dialogue:
			result = 'dialogue'
		Type.choice:
			result = 'choice'
		Type.condition:
			result = 'condition'
		Type.signal_node:
			result = 'signal'
	return result


func set_locale(value: String) -> void:
	locale = value
	Events.emit_signal("locale_changed", value)


func save_file() -> void:
	if current_state == FileState.new:
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return
	if current_state == FileState.saved:
		Serialize.save()
	return


func open_file() -> void:
	if current_state == FileState.unsaved:
		print_debug("file has unsaved change")
		return

	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE
