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
	save_as(current_path)


func load(path: String):
	Editor.reset()

	print_debug("load %s" % path)

	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()

	var parsed_result = JSON.parse(content)
	if parsed_result.error != OK:
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"error while parsing json of %s" % path
		)
		return

	if not Editor.generate_graph(parsed_result.result):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"%s seems incompatible couldn't be loaded" % path
		)
		return

	current_path = path
	Events.emit_signal(
		"notification_displayed", Editor.Notification.success, "%s has been loaded" % path
	)
