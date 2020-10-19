extends Node
class_name Parser


func to_json(json: Dictionary) -> String:
	json["__editor"] = _get_editor_data()
	return JSON.print(json)


func export_to_json(json: Dictionary) -> String:
	return JSON.print(json)


func _get_editor_data() -> Dictionary:
	var json = Store.json
	var result: Dictionary = {
		"root": {},
		"dialogues": [],
		"conditions": [],
		"signals": [],
		"choices": [],
	}

	result.root = Store.root_node.values.__editor

	for key in Store.dialogues_node:
		result.dialogues.append(Store.dialogues_node[key].__editor)

	for key in Store.conditions_node:
		if not Store.has_node_in_json(Store.conditions_node[key].__editor.uuid):
			Store.conditions_node[key].__editor["data"] = Store.conditions_node[key].data.duplicate(
				true
			)
		result.conditions.append(Store.conditions_node[key].__editor)

	for key in Store.signals_node:
		if not Store.has_node_in_json(Store.signals_node[key].__editor.uuid):
			Store.signals_node[key].__editor["data"] = Store.signals_node[key].data.duplicate(true)
		result.signals.append(Store.signals_node[key].__editor)

	for key in Store.choices_node:
		if not Store.has_node_in_json(Store.choices_node[key].__editor.uuid):
			Store.choices_node[key].__editor["data"] = Store.choices_node[key].data.duplicate(
				true
			)
		result.choices.append(Store.choices_node[key].__editor)

	return result
