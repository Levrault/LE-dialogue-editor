extends Node

var current_path := ''


func save_as(path: String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(Store.to_json())
	file.close()
	current_path = path
	Editor.current_state = Editor.FileState.saved
	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "%s has been saved" % path
	)


func save() -> void:
	var file = File.new()
	file.open(current_path, File.WRITE)
	file.store_string(Store.to_json())
	file.close()
	Editor.current_state = Editor.FileState.saved
	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "%s has been saved" % current_path
	)


func load(path: String):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	Editor.current_state = Editor.FileState.saved
	var parsed_result = JSON.parse(content)
	if parsed_result.error != OK:
		print("load json: error while parsing")
		return
	Editor.generate_graph(parsed_result.result)
	current_path = path
	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "%s has been saved" % path
	)
