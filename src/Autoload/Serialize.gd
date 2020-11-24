extends Node

var Parser = load("res://src/Utils/Parser.gd")
var current_path := ""

onready var parser = Parser.new()


func save_as(path: String, editor_compatible := true, silent := false) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(
		parser.to_json(Store.json) if editor_compatible else parser.export_to_json(Store.json)
	)
	file.close()

	if editor_compatible:
		current_path = path

		if not silent:
			Events.emit_signal(
				"notification_displayed", Editor.Notification.success, "%s has been saved" % path
			)
			return

	if not silent:
		Events.emit_signal(
			"notification_displayed", Editor.Notification.success, "%s has been exported" % path
		)


func save() -> void:
	save_as(current_path)


func load(path: String, silent := false):
	print_debug("load %s" % path)

	Editor.is_loading = true
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

	if not FileReader.import(parsed_result.result):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"%s seems incompatible couldn't be loaded" % path
		)
		return

	current_path = path
	if not silent:
		Events.emit_signal(
			"notification_displayed", Editor.Notification.success, "%s has been loaded" % path
		)

	Editor.is_loading = false
