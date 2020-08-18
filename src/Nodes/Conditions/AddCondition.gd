extends AddButton


func on_Pressed() -> void:
	if owner.input.text.empty():
		return

	# add values
	owner.values[owner.input.text] = true

	# add field
	var new_condition = owner.condition.instance()
	owner.container.add_child(new_condition)
	new_condition.value.text = owner.input.text
	new_condition.connect("field_deleted", owner, "_on_Condition_deleted")

	# set for next conditions
	owner.input.text = ""
	owner.add_field.is_disabled = true
