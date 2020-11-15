extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	Config.values.variables.characters.erase(owner.form_values)
	Config.save(Config.values, Editor.project.project)
	owner.reset_form()
	Events.emit_signal("characters_list_changed")
