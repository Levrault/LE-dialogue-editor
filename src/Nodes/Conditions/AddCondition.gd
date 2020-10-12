extends AddButton


func on_Pressed() -> void:
	if owner.input.text.empty():
		Events.emit_signal(
			"notification_displayed", Editor.Notification.error, "ERROR: input can't be empty"
		)
		return

	if is_disabled:
		return

	if owner.input.text == "next":
		Events.emit_signal(
			"notification_displayed", Editor.Notification.error, "ERROR: next is a reserved word"
		)
		return

	# add field
	var new_condition = owner.condition_field.instance()
	owner.container.add_child(new_condition)
	new_condition.name_field.text = owner.input.text
	if owner.selected_type == owner.Type.boolean:
		# set boolean value
		new_condition.value.text = "true" if owner.boolean_field.field.pressed else "false"
		new_condition.operator.text = "equal"

		# add values
		owner.values.data[owner.input.text] = {
			value = owner.boolean_field.field.pressed, operator = "equal", type = "boolean"
		}

		# clear input
		owner.boolean_field.field.pressed = false

	elif owner.selected_type == owner.Type.number:
		# clear input
		new_condition.value.text = owner.number_field.field.text
		new_condition.operator.text = owner.number_field.operator

		# clear input
		owner.number_field.field.text = ""

		# add values
		owner.values.data[owner.input.text] = int(new_condition.value.text)
		owner.values.data[owner.input.text] = {
			value = int(new_condition.value.text),
			operator = owner.number_field.operator,
			type = "int"
		}

	new_condition.connect("field_deleted", owner, "_on_Deleted")

	# set for next conditions
	owner.input.text = ""
	owner.add_field.is_disabled = true
	owner.callback()
	Events.emit_signal("condition_value_added")
