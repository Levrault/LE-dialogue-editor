# Manage editor interaction
extends Node

enum Type { root, dialogue, choice, condition, signal_node }
enum FileState { new, opened, unsaved, saved, export_file }
enum Notification { idle, warning, error, success }

var current_state = FileState.new setget set_current_state
var previous_state = current_state
var locale := "en" setget set_locale
var graph_edit: GraphEdit = null

onready var root_node := load("res://src/Nodes/Root/RootNode.tscn")
onready var dialogue_node := load("res://src/Nodes/Dialogue/DialogueNode.tscn")
onready var choice_node := load("res://src/Nodes/Choice/ChoiceNode.tscn")
onready var condition_node := load("res://src/Nodes/Conditions/ConditionNode.tscn")
onready var signal_node := load("res://src/Nodes/Signal/SignalNode.tscn")


func reset() -> void:
	current_state = FileState.new
	self.locale = "en"

	Serialize.current_path = ""
	Store.json_raw = {}
	Store.choices_node = {}
	Store.conditions_node = {}
	Store.signals_node = {}
	Store.dialogues_node = {}
	Store.dialogues_uuid = []

	for child in graph_edit.get_children():
		if child is GraphEditorNode:
			child.queue_free()


func type_to_string(value: int) -> String:
	var result := ''
	match value:
		Type.root:
			result = 'root'
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


func set_current_state(new_state: int) -> void:
	previous_state = current_state
	current_state = new_state


func save_file() -> void:
	if (
		current_state == FileState.new
		or current_state == FileState.export_file
		or (current_state == FileState.unsaved and Serialize.current_path.empty())
	):
		Events.emit_signal("file_dialog_opened", 4)  # FileDialog.Mode.MODE_SAVE_FILE
		return
	if current_state == FileState.saved or current_state == FileState.unsaved:
		Serialize.save()
	return


func new_file() -> void:
	reset()
	get_tree().reload_current_scene()


func open_file() -> void:
	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 0)  # FileDialog.Mode.MODE_OPEN_FILE


func open_folder() -> void:
	current_state = Editor.FileState.opened
	Events.emit_signal("file_dialog_opened", 2)  # FileDialog.Mode.MODE_OPEN_DIR


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

	var root = json["root"].duplicate()
	json.erase("root")

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
				var saved_data = _find_by_uuid(editor_data.conditions, uuid)
				var condition_instance = _load_node(
					uuid, condition_node.instance(), condition.duplicate(), saved_data.duplicate()
				)
				if condition_instance:
					conditions_list.append(condition_instance)

		if json[uuid].has("signals"):
			var saved_data = _find_by_uuid(editor_data.signals, uuid)
			_load_node(
				uuid, signal_node.instance(), json[uuid].signals.duplicate(), saved_data.duplicate()
			)

		if json[uuid].has("choices"):
			for choice in json[uuid].choices:
				var saved_data = _find_by_uuid(editor_data.choices, uuid)
				var choice_instance = _load_node(
					uuid, choice_node.instance(), choice.duplicate(), saved_data.duplicate()
				)
				if choice_instance:
					choices_list.append(choice_instance)

	# create root node
	var root_instance = root_node.instance()
	root_instance.uuid = "root"
	root_instance.values["__editor"] = editor_data.root.duplicate()
	Events.emit_signal("graph_node_loaded", root_instance)
	print(root)
	if root.has("conditions"):
		for condition in root.conditions:
			if not condition.has("next"):
				continue
			if condition.next.empty():
				continue
			var saved_data = _find_by_uuid(editor_data.conditions, "root")
			var condition_instance = _load_node(
				"root", condition_node.instance(), condition.duplicate(), saved_data.duplicate()
			)
			if condition_instance:
				conditions_list.append(condition_instance)
	elif root.has("next") and not root.next.empty():
		Events.emit_signal(
			"connection_request_loaded", root_instance.uuid, 0, root.next, 0
		)

	for dialogue in dialogue_list:
		var values = dialogue.values.data
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


# Load node and add it to the graphedit
func _load_node(
	uuid: String, node_instance: GraphEditorNode, data: Dictionary, editor_data: Dictionary
) -> GraphEditorNode:
	if not editor_data:
		return null

	node_instance.uuid = editor_data.uuid
	node_instance.is_loading = true
	node_instance.values.data = data
	node_instance.values["__editor"] = editor_data

	Events.emit_signal("graph_node_loaded", node_instance)
	Events.emit_signal("connection_request_loaded", uuid, 0, node_instance.uuid, 0)
	return node_instance
