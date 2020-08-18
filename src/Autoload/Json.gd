extends Node

const BBCODE_DIALOGUE_TEMPLATE = {
	"uuid": "[color=#ef5350]%uuid%[/color] {\n",
	"root": "    root: true\n",
	"conditions": "	[color=#03a9f4]conditions[/color]: {\n%conditions% \n	}\n",
	"signals": "	[color=#03a9f4]signals[/color]: {\n%signals% \n	}\n",
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

const BBCODE_CONDITIONS_TEMPLATE := {
	"condition": "			[color=#ef5350]%key%[/color]: %value%",
	"line_close_coma": ',\n',
	"line_close_no_coma": '',
}

const BBCODE_SIGNALS_TEMPLATE := {
	"signals": "			[color=#4db6ac]%key%[/color]: %value%",
	"string": '{\n 				String: %value%\n 			}',
	"vector2": '{\n				Vector2: {\n					x: %x%\n					y: %y%\n				}\n			}',
	"number": '{\n				Float: %value%\n			}',
	"line_close_coma": ',\n',
	"line_close_no_coma": '',
}

# single quote to escape double quote
const DIALOGUE_STRING_TEMPLATE = {
	"uuid": '  "%uuid%": {\n',
	"root": '    "root": true,\n',
	"signals": '    "signals": {\n%signals%    },\n',
	"conditions": '    "conditions": {\n%conditions%    },\n',
	"name": '    "name": "%name%",\n',
	"portrait": '    "portrait": "%portrait%",\n',
	"text": '    "text": {\n',
	"en": '      "en": "%en%",\n',
	"fr": '      "fr": "%fr%"\n',
	"line": "    },\n",
	"choices": '    "choices":[\n %choices%]\n',
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

const CONDITIONS_TEMPLATE := {
	"condition": '			"%key%": %value%',
	"line_close_coma": ',\n',
	"line_close_no_coma": '\n',
}

const SIGNALS_TEMPLATE := {
	"signals": '      "%key%": %value%',
	"string": '{\n        "String": "%value%"\n      }',
	"vector2":
	'{\n        "Vector2": {\n          "x": %x%,\n          "y": %y%\n        }\n      }',
	"number": '{\n        "Float": %value%\n      }',
	"line_close_coma": ',\n',
	"line_close_no_coma": '\n',
}

var json_raw := {}
var dialogue_raw_default := {"name": "", "portrait": "", "text": {"en": "", "fr": ""}}
var choices_node := {}
var conditions_node := {}
var signals_node := {}
var dialogues_uuid := []


func _ready() -> void:
	Events.connect("dialogue_node_created", self, "_on_Dialogue_node_created")
	Events.connect("choice_node_created", self, "_on_Choice_node_created")
	Events.connect("condition_node_created", self, "_on_Condition_node_created")
	Events.connect("signal_node_created", self, "_on_Signal_node_created")

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

	# dialogue to conditions
	Events.connect(
		"dialogue_to_condition_relation_created", self, "_on_Dialogue_to_condition_relation_created"
	)

	# Dialogue to signal
	Events.connect(
		"dialogue_to_signal_relation_created", self, "_on_Dialogue_to_signal_relation_created"
	)
	Events.connect(
		"dialogue_to_signal_relation_deleted", self, "_on_Dialogue_to_signal_relation_deleted"
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
	return stringify(
		BBCODE_DIALOGUE_TEMPLATE,
		BBCODE_CHOICE_TEMPLATE,
		BBCODE_CONDITIONS_TEMPLATE,
		BBCODE_SIGNALS_TEMPLATE
	)


func to_string() -> String:
	return (
		"{\n"
		+ stringify(
			DIALOGUE_STRING_TEMPLATE, CHOICE_STRING_TEMPLATE, CONDITIONS_TEMPLATE, SIGNALS_TEMPLATE
		)
		+ "\n}"
	)


# Read template dictionary to correctly format string
# Use to display as bb_code
# Use to export to a correctly formatted json (since we don't to have dependancie)
# 	For json export, a check must be done to manage closing coma, this isn't sexy but it works
#	Work by deleting the UNUSED dictionnary key e.g. don't want coma, delete the coma key
func stringify(
	dialogue_string_template: Dictionary,
	choice_string_template: Dictionary,
	conditions_string_template: Dictionary,
	signals_string_template: Dictionary
) -> String:
	var result := ""
	var d_index := 0
	for uuid in json_raw:
		var node_data = json_raw[uuid]
		var template: Dictionary = dialogue_string_template.duplicate()
		template.uuid = template.uuid.replace("%uuid%", uuid)
		template.name = template.name.replace("%name%", node_data.name)
		template.portrait = template.portrait.replace("%portrait%", node_data.portrait)
		template.en = template.en.replace("%en%", node_data.text.en)
		template.fr = template.fr.replace("%fr%", node_data.text.fr)

		if not node_data.has("root"):
			template.erase("root")

		# conditions
		if node_data.has("conditions"):
			var conditions_string := ""
			var c_index := 0
			for condition_key in node_data.conditions:
				var conditions_template := conditions_string_template.duplicate()
				conditions_template.condition = conditions_template.condition.replace("%key%", condition_key).replace(
					"%value%", str(node_data.conditions[condition_key]).to_lower()
				)

				if c_index != node_data.conditions.size() - 1:
					conditions_template.erase("line_close_no_coma")
				else:
					conditions_template.erase("line_close_coma")

				for key in conditions_template:
					conditions_string += conditions_template[key]

				c_index += 1
			template.conditions = template.conditions.replace("%conditions%", conditions_string)

		else:
			template.erase("conditions")

		if node_data.has("signals"):
			print(node_data.signals)
			var signals_string := ""
			var s_index := 0
			for signal_dic in node_data.signals:
				for signal_key in signal_dic:
					var signals_template := signals_string_template.duplicate()
					var value := 'null'

					signals_template.signals = signals_template.signals.replace("%key%", signal_key)

					if signal_dic[signal_key].has("Vector2"):
						value = signals_template.vector2.replace("%x%", signal_dic[signal_key]["Vector2"].x).replace(
							"%y%", signal_dic[signal_key]["Vector2"].y
						)
					elif signal_dic[signal_key].has("String"):
						value = signals_template["string"].replace(
							"%value%", signal_dic[signal_key]["String"]
						)
					elif signal_dic[signal_key].has("Number"):
						value = signals_template["number"].replace(
							"%value%", signal_dic[signal_key]["Number"]
						)

					signals_template.signals = signals_template.signals.replace("%value%", value)

					signals_template.erase("vector2")
					signals_template.erase("number")
					signals_template.erase("string")

					if s_index != signal_dic.size() - 1:
						signals_template.erase("line_close_no_coma")
					else:
						signals_template.erase("line_close_coma")

					for key in signals_template:
						signals_string += signals_template[key]

					s_index += 1
			template.signals = template.signals.replace("%signals%", signals_string)

		else:
			template.erase("signals")

		# choice
		if node_data.has("choices"):
			var c_index := 0
			var choices_string := ""
			for choice in node_data.choices:
				var choice_template = choice_string_template.duplicate()
				choice_template.en = choice_template.en.replace("%en%", choice.text.en)
				choice_template.fr = choice_template.fr.replace("%fr%", choice.text.fr)
				choice_template.next = choice_template.next.replace("%next%", choice.next)

				if c_index != node_data.choices.size() - 1:
					choice_template.erase("line_close_no_coma")
				else:
					choice_template.erase("line_close_coma")

				for key in choice_template:
					choices_string += choice_template[key]
				c_index += 1
			template.choices = template.choices.replace("%choices%", choices_string)
		else:
			template.erase("choices")

		if node_data.has("next"):
			template.next = template.next.replace("%next%", node_data.next)
		else:
			template.erase("next")
			if not template.has("choices"):
				template.line = "    }\n"

		if d_index != json_raw.size() - 1:
			template.erase("line_close_no_coma")
		else:
			template.erase("line_close_coma")

		for key in template:
			result += template[key]
		d_index += 1

	return result


func _on_Dialogue_node_created(data: Dictionary) -> void:
	if json_raw.empty():
		print(data)
		data.values["root"] = true

	json_raw[data.uuid] = data.values
	dialogues_uuid.append(data.uuid)


func _on_Choice_node_created(data: Dictionary) -> void:
	choices_node[data.uuid] = data.values


func _on_Condition_node_created(data: Dictionary) -> void:
	conditions_node[data.uuid] = data.values


func _on_Signal_node_created(data: Dictionary) -> void:
	signals_node[data.uuid] = data.values


func _on_Start_to_dialogue_relation_changed(from: String) -> void:
	# remove previous first
	for uuid in dialogues_uuid:
		if json_raw[uuid].has("root"):
			json_raw[uuid].erase("root")

	# new one 
	dialogues_uuid.push_front(from)
	json_raw[from]["root"] = true

	# re-order structure : Lazy way, destroy and rebuild
	var previous_json_raw := json_raw.duplicate()
	json_raw = {}
	for uuid in dialogues_uuid:
		json_raw[uuid] = previous_json_raw[uuid]


func _on_Dialogue_to_dialogue_relation_created(from: String, to: String) -> void:
	json_raw[from]["next"] = to


func _on_Dialogue_to_dialogue_relation_deleted(from: String) -> void:
	json_raw[from].erase("next")


func _on_Dialogue_to_condition_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("conditions"):
		json_raw[from]["conditions"] = []
	json_raw[from].conditions = conditions_node[to]


func _on_Dialogue_to_choice_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("choices"):
		json_raw[from]["choices"] = []
	json_raw[from].choices.append(choices_node[to])


func _on_Dialogue_to_choice_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["choices"].erase(choices_node[to])


func _on_Dialogue_to_signal_relation_created(from: String, to: String) -> void:
	if not json_raw[from].has("signals"):
		json_raw[from]["signals"] = []
	json_raw[from].signals.append(signals_node[to])


func _on_Dialogue_to_signal_relation_deleted(from: String, to: String) -> void:
	json_raw[from]["signals"].erase(signals_node[to])


func _on_Choice_to_dialogue_relation_created(from: String, to: String) -> void:
	choices_node[from].next = to


func _on_Choice_to_dialogue_relation_deleted(from: String) -> void:
	choices_node[from].next = ""
