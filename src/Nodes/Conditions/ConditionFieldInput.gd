extends FieldInput


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		owner.add_field.on_Pressed()
