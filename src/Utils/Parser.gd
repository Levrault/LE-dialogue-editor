# Export data from Store to a compatible json file
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
		_parse_self_containted_data(
			Store.conditions_node[key].__editor.get("parent"),
			Store.conditions_node[key].__editor,
			Store.conditions_node[key].get("data")
		)
		result.conditions.append(Store.conditions_node[key].__editor)

	for key in Store.signals_node:
		_parse_self_containted_data(
			Store.signals_node[key].__editor.get("parent"),
			Store.signals_node[key].__editor,
			Store.signals_node[key].get("data")
		)
		result.signals.append(Store.signals_node[key].__editor)

	for key in Store.choices_node:
		_parse_self_containted_data(
			Store.choices_node[key].__editor.get("parent"),
			Store.choices_node[key].__editor,
			Store.choices_node[key].get("data")
		)
		result.choices.append(Store.choices_node[key].__editor)

	return result


# If the isn't connected to any dialogue, we save his data inside the __editor dictionary
# @param {String} parent_uuid of parent
# @param {Dictionary} __editor - use directly the ref (no .duplicate)
# @param {Dictionary} data - use directly the ref (no .duplicate)
func _parse_self_containted_data(parent_uuid, __editor: Dictionary, data: Dictionary) -> void:
	if not parent_uuid or not Store.has_node_in_json(parent_uuid):
		__editor["data"] = data.duplicate(true)
		return

	__editor.erase("data")
