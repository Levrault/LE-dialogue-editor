# Save or update a character
extends Button


func _ready() -> void:
	connect("pressed", self, "_on_Pressed")


func _on_Pressed() -> void:
	if owner.is_edit_character_mode:
		Config.save(Config.values)
		Events.emit_signal("characters_list_changed")

		Events.emit_signal(
			"notification_displayed",
			Editor.Notification.success,
			"%s has been updated" % [owner.form_values.name]
		)
		owner.reset_form()
		return

	Config.values.variables.characters.append(owner.form_values.duplicate(true))
	Config.save(Config.values)
	Events.emit_signal(
		"notification_displayed",
		Editor.Notification.success,
		"%s has been added" % [owner.form_values.name]
	)
	owner.reset_form()
	Events.emit_signal("characters_list_changed")
