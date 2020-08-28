extends Node

var Parser = load("res://src/Utils/Parser.gd")
var current_path := ""

onready var parser = Parser.new()


func save_as(path: String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(parser.to_json(Store.json_raw))
	file.close()
	current_path = path
	Editor.current_state = Editor.FileState.saved
	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "%s has been saved" % path
	)


func save() -> void:
	print(Store.json_raw["f119a6c2-c008-481c-b67e-83149c50e3e3"].choices)
	save_as(current_path)


func load(path: String):
	Editor.reset()

	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()

	var parsed_result = JSON.parse(content)
	if parsed_result.error != OK:
		print("load json: error while parsing")
		return

	if Editor.generate_graph(parsed_result.result):
		current_path = path
		Events.emit_signal(
			"notification_displayed", Editor.Notification.success, "%s has been loaded" % path
		)
