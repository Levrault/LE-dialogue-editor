extends LineEdit


func _ready() -> void:
	connect("text_changed", self, "_on_Text_changed")


func _on_Text_changed(new_text: String) -> void:
	owner.form_values["name"] = new_text
	owner.save_character.disabled = false
	
	if not owner.cancel_character.visible:
		owner.cancel_character.show()
