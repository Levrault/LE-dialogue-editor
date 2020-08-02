extends Node

var json_raw := {
}

var dialogue_raw_default := {
	"name": "",
	"portrait": "",
	"text": {
		"en": "",
		"fr": ""
	}
}

var choices_node := {}


func _ready() -> void:
	Events.connect("dialogue_node_created", self, "_on_Dialogue_node_created")
	Events.connect("choice_node_created", self, "_on_Choice_node_created")

	# Dialogue to dialogue
	Events.connect("dialogue_to_dialogue_relation_created", self, "_on_Dialogue_to_dialogue_relation_created")
	Events.connect("dialogue_to_dialogue_relation_deleted", self, "on_Dialogue_to_dialogue_relation_deleted")

	# Dialogue to choice
	Events.connect("dialogue_to_choice_relation_created", self, "_on_Dialogue_to_choice_relation_created")
	Events.connect("dialogue_to_choice_relation_deleted", self, "_on_Dialogue_to_choice_relation_deleted")

	# Choice to dialogue
	Events.connect("choice_to_dialogue_relation_created", self, "_on_Choice_to_dialogue_relation_created")
	Events.connect("choice_to_dialogue_relation_deleted", self, "_on_Choice_to_dialogue_relation_deleted")


func get_dialogue_template_string() -> Dictionary:
	var template := {
		"uuid": "[color=#ef5350]%uuid%[/color] {\n",
		"name": "	[color=#2196f3]name[/color]: %name%,\n",
		"portrait": "	[color=#2196f3]portrait[/color]: %portrait%,\n",
		"text": "	[color=#2196f3]text[/color]: {\n",
		"en": "		en: %en%\n",
		"fr": "		fr: %fr%\n",
		"line": "	},\n",
		"choices": "	[color=#03a9f4]choices[/color]:[\n %choices% \n		]\n",
		"next": "	[color=#009688]next[/color]: %next%\n",
		"line2": "}\n",
	}
	return template


func get_choice_template_string() -> Dictionary:
	var template := {
		"line_open": "		{\n",
		"text": "			[color=#2196f3]text[/color]: {\n",
		"en": "				en: %en%\n",
		"fr": "				fr: %fr%\n",
		"line_close": "			},\n",
		"next": "			[color=#009688]next[/color]: %next%\n",
	}
	return template


func _on_Dialogue_node_created(data: Dictionary) -> void:
	json_raw[data.uuid] = data.values


func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values
	print(choices_node)


func _on_Dialogue_to_dialogue_relation_created(from, to) -> void:
	json_raw[from]["next"] = to
	print(json_raw)


func _on_Dialogue_to_dialogue_relation_delete(from, to) -> void:
	pass


func _on_Dialogue_to_choice_relation_created(from, to) -> void:
	if not json_raw[from].has("choices"):
		json_raw[from]["choices"] = []
	json_raw[from]["choices"].append(choices_node[to])
	print(json_raw[from]["choices"])


func _on_Dialogue_to_choice_relation_deleted(from, to) -> void:
	pass


func _on_Choice_to_dialogue_relation_created(from, to) -> void:
	choices_node[from].next = to


func _on_Choice_to_dialogue_relation_deleted(from, to) -> void:
	pass
