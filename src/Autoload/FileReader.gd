extends Node


# Recreate the graph based on the json file
# Will recreated all linked nodes first
# and add lonely node afterward
# @param {Dictionary} json
# @returns {bool} - loading finished
func import(json: Dictionary) -> bool:
	if not json.has("__editor"):
		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.error,
			"This file was not created with Levrault Editor and is not supported"
		)
		return false

	var editor_data = json["__editor"].duplicate(true)
	var dialogue_list := []
	var choices_list := []
	var conditions_list := []
	json.erase("__editor")

	var root = json["root"].duplicate(true)
	json.erase("root")

	# construct all connected nodes from dialogue node
	for uuid in json:
		var dialogue_instance = Editor.dialogue_node.instance()
		var dialogue_saved_data = _find_by_uuid(editor_data.dialogues, uuid)
		dialogue_instance.uuid = dialogue_saved_data.uuid
		dialogue_instance.values.data = json[uuid]
		dialogue_instance.values["__editor"] = dialogue_saved_data
		dialogue_list.append(dialogue_instance)
		Events.emit_signal("graph_node_loaded", dialogue_instance)

		if json[uuid].has("conditions"):
			for condition in json[uuid].conditions:
				var saved_data = _find_by_uuid(editor_data.conditions, uuid)
				var condition_instance = _load_node(
					uuid, Editor.condition_node.instance(), condition, saved_data
				)
				if condition_instance:
					conditions_list.append(condition_instance)

		if json[uuid].has("signals"):
			var saved_data = _find_by_uuid(editor_data.signals, uuid)
			_load_node(uuid, Editor.signal_node.instance(), json[uuid].signals, saved_data)

		if json[uuid].has("choices"):
			for choice in json[uuid].choices:
				var saved_data = _find_by_uuid(editor_data.choices, uuid)
				var choice_instance = _load_node(
					uuid, Editor.choice_node.instance(), choice, saved_data
				)
				if choice_instance:
					choices_list.append(choice_instance)

	# create root node
	var root_instance = Editor.root_node.instance()
	root_instance.uuid = "root"
	root_instance.name = "root"
	root_instance.values["__editor"] = editor_data.root
	Events.emit_signal("graph_node_loaded", root_instance)

	# import node non connected to a dialogue node
	_import_unconnected_node(editor_data)

	# connect nodes, data are stocked inside the dialogue object
	if root.has("conditions"):
		for condition in root.conditions:
			var saved_data = _find_by_uuid(editor_data.conditions, "root")
			var condition_instance = _load_node(
				"root", Editor.condition_node.instance(), condition, saved_data
			)
			if condition_instance:
				conditions_list.append(condition_instance)
	elif root.has("next") and not root.next.empty():
		Events.emit_signal("connection_request_loaded", root_instance.uuid, 0, root.next, 0)

	for dialogue in dialogue_list:
		var values = dialogue.values.data
		if values.has("next"):
			Events.emit_signal("connection_request_loaded", dialogue.uuid, 0, values.next, 0)

	for choice in choices_list:
		var values = choice.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", choice.uuid, 0, values.next, 0)

	for condition in conditions_list:
		var values = condition.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", condition.uuid, 0, values.next, 0)

	Events.emit_signal("file_loaded")
	return true


# Create node that aren't related to any node and add them to GraphEditor scene
# They have their own data, saved inside __editor (data key)
# @param {Dictionary} editor_data
func _import_unconnected_node(editor_data: Dictionary) -> void:
	var conditions_list := []
	var signals_list := []
	var choices_list := []

	# unconnected node, data are inside the node itself (until they are gonna be connected)
	for condition in editor_data.conditions:
		if condition.has("data"):
			var condition_instance = _load_node(
				"", Editor.condition_node.instance(), condition.data, condition
			)
			if condition_instance:
				conditions_list.append(condition_instance)

	for choice in editor_data.choices:
		if choice.has("data"):
			var choice_instance = _load_node("", Editor.choice_node.instance(), choice.data, choice)
			if choice_instance:
				choices_list.append(choice_instance)

	# unconnected node, data are inside the node itself (until they are gonna be connected)
	for signal_dic in editor_data.signals:
		if signal_dic.has("data"):
			_load_node("", Editor.signal_node.instance(), signal_dic.data, signal_dic)

	for condition in conditions_list:
		var values = condition.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", condition.uuid, 0, values.next, 0)

	for choice in choices_list:
		var values = choice.values.data
		if values.has("next") and not values.next.empty():
			Events.emit_signal("connection_request_loaded", choice.uuid, 0, values.next, 0)


# get and remove uuid from array
# Array should be data from __editor (eg. __editor.conditions)
# @param {array} data
# @param {String} uuid
# @returns {Dictionary}
func _find_by_uuid(data: Array, uuid: String) -> Dictionary:
	for id in data:
		if id.uuid == uuid or (id.has("parent") and id.parent == uuid):
			data.erase(id)
			return id.duplicate()

	return {}


# Some kind of factory that create and add node to GraphEditor scene
# @param {String} uuid
# @param {GraphEditorNode} node_instance - choice_node, condition_node, dialogue_node, signal_node
# @param {Dictionary} data - data from dialogue or the itself (if isn't connected to any dialogue)
# @param {Dictionary} editor_data - data from __editor
# @returns {GraphEditorNode} - created instance
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
	if not uuid.empty():
		Events.emit_signal("connection_request_loaded", uuid, 0, node_instance.uuid, 0)
	return node_instance
