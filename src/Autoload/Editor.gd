extends Node

enum Type { start, dialogue, choice, condition, signal_node }
enum FileState { new, opened, unsaved, saved }
enum Notification { idle, warning, error, success }

var current_state = FileState.new
var locale := 'en' setget set_locale

onready var dialogue_node := load("res://src/Nodes/Dialogue/DialogueNode.tscn")
onready var choice_node := load("res://src/Nodes/Choice/ChoiceNode.tscn")
onready var condition_node := load("res://src/Nodes/Conditions/ConditionNode.tscn")
onready var signal_node := load("res://src/Nodes/Signal/SignalNode.tscn")


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
	print(Store.json_raw)
	if current_state == FileState.new:
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return
	if current_state == FileState.unsaved or current_state == FileState.saved:
		Serialize.save()
	return


func open_file() -> void:
	if current_state == FileState.unsaved:
		print_debug("file has unsaved change")
		return

	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func generate_graph(json: Dictionary) -> bool:
	if not json.has("__editor"):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"This file was not created with Levrault Editor and is not supported"
		)
		return false
	var editor_data = json["__editor"].duplicate()
	var dialogue_list := []
	var choices_list := []
	var conditions_list := []
	json.erase("__editor")

	# create instance
	for uuid in json:
		var dialogue_instance = dialogue_node.instance()
		var dialogue_saved_data = _find_by_uuid(editor_data.dialogues, uuid)
		dialogue_instance.uuid = dialogue_saved_data.uuid
		dialogue_instance.values.data = json[uuid].duplicate()
		dialogue_instance.values["__editor"] = dialogue_saved_data.duplicate()
		dialogue_list.append(dialogue_instance)
		Events.emit_signal("graph_node_loaded", dialogue_instance)

		if json[uuid].has("conditions"):
			for condition in json[uuid].conditions:
				var condition_instance = condition_node.instance()
				var saved_data = _find_by_uuid(editor_data.conditions, uuid)
				if not saved_data.empty():
					condition_instance.uuid = saved_data.uuid
					condition_instance.values.data = condition.duplicate()
					condition_instance.values["__editor"] = saved_data.duplicate()
					conditions_list.append(condition_instance)
					Events.emit_signal("graph_node_loaded", condition_instance)
					Events.emit_signal(
						"connection_request_loaded", uuid, 0, condition_instance.uuid, 0
					)

		if json[uuid].has("signals"):
			var signals_instance = signal_node.instance()
			var saved_data = _find_by_uuid(editor_data.signals, uuid)
			signals_instance.uuid = saved_data.uuid
			signals_instance.values.data = json[uuid].signals.duplicate()
			signals_instance.values["__editor"] = saved_data.duplicate()
			dialogue_instance.connected_to_signal = signals_instance.uuid
			Events.emit_signal("graph_node_loaded", signals_instance)
			Events.emit_signal("connection_request_loaded", uuid, 0, saved_data.uuid, 0)

		if json[uuid].has("choices"):
			for choice in json[uuid].choices:
				var choices_instance = choice_node.instance()
				var saved_data = _find_by_uuid(editor_data.choices, uuid)
				if not saved_data.empty():
					choices_instance.uuid = saved_data.uuid
					choices_instance.values.data = choice.duplicate()
					choices_instance.values["__editor"] = saved_data.duplicate()
					choices_list.append(choices_instance)
					Events.emit_signal("graph_node_loaded", choices_instance)
					Events.emit_signal(
						"connection_request_loaded", uuid, 0, choices_instance.uuid, 0
					)

	for dialogue in dialogue_list:
		var values = dialogue.values.data
		if values.has("root"):
			Events.emit_signal("connection_request_loaded", "StartNode", 0, dialogue.uuid, 0)
		if values.has("next"):
			Events.emit_signal("connection_request_loaded", dialogue.uuid, 0, values.next, 0)

	for condition in conditions_list:
		var values = condition.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", condition.uuid, 0, values.next, 0)

	for choice in choices_list:
		var values = choice.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", choice.uuid, 0, values.next, 0)

	Events.emit_signal("file_loaded")
	return true


func _find_by_uuid(data: Array, uuid: String) -> Dictionary:
	for id in data:
		if id.uuid == uuid or (id.has("parent") and id.parent == uuid):
			data.erase(id)
			return id.duplicate()

	return {}
