extends WindowDialog

onready var json := $Container/Json


func _ready():
	connect("about_to_show", self, "_on_About_to_show")


func _on_About_to_show() -> void:
	json.bbcode_text = ""

	for uuid in Json.json_raw:
		var template: Dictionary = Json.get_dialogue_template_string()
		template.uuid = template.uuid.replace("%uuid%", uuid)
		template.name = template.name.replace("%name%", Json.json_raw[uuid].name)
		template.portrait = template.portrait.replace("%portrait%", Json.json_raw[uuid].portrait)
		template.en = template.en.replace("%en%", Json.json_raw[uuid].text.en)
		template.fr = template.fr.replace("%fr%", Json.json_raw[uuid].text.fr)

		if Json.json_raw[uuid].has("choices"):
			var choice_template = Json.get_dialogue_template_string()
			var choices := ""
			for choice in Json.json_raw[uuid].choices:
				choice_template.text = choice_template.text.replace("text",  choice.text)
				choice_template.en = choice_template.text.replace("en",  choice.en)
				choice_template.fr = choice_template.text.replace("fr",  choice.fr)
				choice_template.next = choice_template.text.replace("next",  choice.next)

				for key in choice:
					choices += choice[key]

			template.choices = choices
		else:
			template.erase("choices")



		if Json.json_raw[uuid].has("next"):
			template.next = template.next.replace("%next%", Json.json_raw[uuid].next)
		else:
			template.erase("next")

		for key in template:
			json.bbcode_text += template[key]

