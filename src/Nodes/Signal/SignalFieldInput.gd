extends FieldInput


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and owner.is_submitable():
		owner.add_field.on_Pressed()


func _on_Text_changed(new_text: String) -> void:
	if not owner.is_submitable():
		owner.add_field.is_disabled = true
		return

	._on_Text_changed(new_text)
