extends Node

const BBCODE_DIALOGUE_TEMPLATE = {
	"uuid": "[color=#ef5350]%uuid%[/color] {\n",
	"name": "	[color=#2196f3]name[/color]: [color=#fdd835]%name%[/color],\n",
	"portrait": "	[color=#2196f3]portrait[/color]: [color=#fdd835]%portrait%[/color],\n",
	"text": "	[color=#2196f3]text[/color]: {\n",
	"en": "		en: [color=#fdd835]%en%[/color]\n",
	"fr": "		fr: [color=#fdd835]%fr%[/color]\n",
	"line": "	},\n",
	"choices": "	[color=#03a9f4]choices[/color]:[\n %choices% \n		]\n",
	"next": "	[color=#009688]next[/color]: [color=#fdd835]%next%[/color]\n",
	"line2": "}\n",
}

const BBCODE_CHOICE_TEMPLATE := {
	"line_open": "		{\n",
	"text": "			[color=#2196f3]text[/color]: {\n",
	"en": "				en: [color=#fdd835]%en%[/color]\n",
	"fr": "				fr: [color=#fdd835]%fr%[/color]\n",
	"line_close": "			},\n",
	"next": "			[color=#009688]next: %next%[/color]\n",
}

# single quote to escape double quote
const DIALOGUE_STRING_TEMPLATE = {
	"uuid": '  "%uuid%": {\n',
	"name": '    "name": "%name%",\n',
	"portrait": '    "portrait": "%portrait%",\n',
	"text": '    "text": {\n',
	"en": '      "en": "%en%",\n',
	"fr": '      "fr": "%fr%"\n',
	"line": "    },\n",
	"choices": '    "choices":[\n %choices%    ]\n',
	"next": '    "next": "%next%"\n',
	"line_close_coma": "  },\n",
	"line_close_no_coma": "  }",
}

const CHOICE_STRING_TEMPLATE := {
	"line_open": "      {\n",
	"text": '        "text": {\n',
	"en": '          "en": "%en%",\n',
	"fr": '          "fr": "%fr%"\n',
	"line_close": '        },\n',
	"next": '        "next": "%next%"\n',
	"line_close_coma": '      },\n',
	"line_close_no_coma": '      }',
}

var json_raw := {}

var dialogue_raw_default := {"name": "", "portrait": "", "text": {"en": "", "fr": ""}}

var choices_node := {}
var dialogues_uuid := []


func _ready() -> void:
	Events.connect("dialogue_node_created", self, "_on_Dialogue_node_created")
	Events.connect("choice_node_created", self, "_on_Choice_node_created")

	# start to dialogue
	Events.connect(
		"start_to_dialogue_relation_changed", self, "_on_Start_to_dialogue_relation_changed"
	)

	# Dialogue to dialogue
	Events.connect(
		"dialogue_to_dialogue_relation_created", self, "_on_Dialogue_to_dialogue_relation_created"
	)
	Events.connect(
		"dialogue_to_dialogue_relation_deleted", self, "_on_Dialogue_to_dialogue_relation_deleted"
	)

	# Dialogue to choice
	Events.connect(
		"dialogue_to_choice_relation_created", self, "_on_Dialogue_to_choice_relation_created"
	)
	Events.connect(
		"dialogue_to_choice_relation_deleted", self, "_on_Dialogue_to_choice_relation_deleted"
	)

	# Choice to dialogue
	Events.connect(
		"choice_to_dialogue_relation_created", self, "_on_Choice_to_dialogue_relation_created"
	)
	Events.connect(
		"choice_to_dialogue_relation_deleted", self, "_on_Choice_to_dialogue_relation_deleted"
	)


func bbcode_to_string() -> String:
	return stringify(BBCODE_DIALOGUE_TEMPLATE, BBCODE_CHOICE_TEMPLATE)


func to_string() -> String:
	return "{\n" + stringify(DIALOGUE_STRING_TEMPLATE, CHOICE_STRING_TEMPLATE) + "\n}"


func stringify(dialogue_string_template: Dictionary, choice_string_template: Dictionary) -> String:
	var result := ""
	var d_index := 0
	for uuid in json_raw:
		var template: Dictionary = dialogue_string_template.duplicate()
		template.uuid = template.uuid.replace("%uuid%", uuid)
		template.name = template.name.replace("%name%", json_raw[uuid].name)
		template.portrait = template.portrait.replace("%portrait%", json_raw[uuid].portrait)
		template.en = template.en.replace("%en%", json_raw[uuid].text.en)
		template.fr = template.fr.replace("%fr%", json_raw[uuid].text.fr)

		if Json.json_raw[uuid].has("choices"):
			var c_index := 0
			var choices_string := ""
			for choice in Json.json_raw[uuid].choices:
				var choice_template = choice_string_template.duplicate()
				choice_template.en = choice_template.en.replace("%en%", choice.text.en)
				choice_template.fr = choice_template.fr.replace("%fr%", choice.text.fr)
				choice_template.next = choice_template.next.replace("%next%", choice.next)

				if c_index != Json.json_raw[uuid].choices.size() - 1:
					choice_template.erase("line_close_no_coma")
				else:
					choice_template.erase("line_close_coma")

				for key in choice_template:
					choices_string += choice_template[key]
				c_index += 1
			template.choices = template.choices.replace("%choices%", choices_string)
		else:
			template.erase("choices")

		if Json.json_raw[uuid].has("next"):
			template.next = template.next.replace("%next%", Json.json_raw[uuid].next)
		else:
			template.erase("next")
			if not template.has("choices"):
				template.line = "    }\n"

		if d_index != Json.json_raw.size() - 1:
			template.erase("line_close_no_coma")
		else:
			template.erase("line_close_coma")

		for key in template:
			result += template[key]
		d_index += 1

	return result


func _on_Dialogue_node_created(data: Dictionary) -> void:
	json_raw[data.uuid] = data.values
	dialogues_uuid.append(data.uuid)


func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values


func _on_Start_to_dialogue_relation_changed(from: String) -> void:
	dialogues_uuid.push_front(from)
	# re-order structure : Lazy way, destroy and rebuild
	var previous_json_raw := json_raw.duplicate()
	json_raw = {}
	for uuid in dialogues_uuid:
		json_raw[uuid] = previous_json_raw[uuid]


func _on_Dialogue_to_dialogue_relation_created(from: String, to: String) -> void:
	json_raw[from]["next"] = to


func _on_Dialogue_to_dialogue_relation_deleted(from: String) -> void:
	json_raw[from].erase("next")


func _on_Dialogue_to_choice_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("choices"):
		json_raw[from]["choices"] = []
	json_raw[from]["choices"].append(choices_node[to])
	print(json_raw[from]["choices"])


func _on_Dialogue_to_choice_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["choices"].erase(choices_node[to])


func _on_Choice_to_dialogue_relation_created(from: String, to: String) -> void:
	choices_node[from].next = to


func _on_Choice_to_dialogue_relation_deleted(from: String) -> void:
	choices_node[from].next = ""
