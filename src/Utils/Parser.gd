extends Node
class_name Parser


func to_json(json_raw: Dictionary) -> String:
	json_raw["__editor"] = _get_editor_data()
	return JSON.print(json_raw)


func _get_editor_data() -> Dictionary:
	var json = Store.json_raw
	var result: Dictionary = {
		"dialogues": [],
		"conditions": [],
		"signals": [],
		"choices": [],
	}

	for key in Store.dialogues_node:
		result.dialogues.append(Store.dialogues_node[key].__editor)

	for key in Store.conditions_node:
		result.conditions.append(Store.conditions_node[key].__editor)

	for key in Store.signals_node:
		result.signals.append(Store.signals_node[key].__editor)

	for key in Store.choices_node:
		result.choices.append(Store.choices_node[key].__editor)

	return result
