extends AddButton


func on_Pressed() -> void:
	if owner.input.text.empty():
		return

	if is_disabled:
		return

	if owner.input.text == "next":
		# print_debug("ERROR: next is a reserved word")
		return

	# add values
	owner.values.data[owner.input.text] = true

	# add field
	var new_condition = owner.condition_field.instance()
	owner.container.add_child(new_condition)
	new_condition.value.text = owner.input.text
	new_condition.connect("field_deleted", owner, "_on_Deleted")

	# set for next conditions
	owner.input.text = ""
	owner.add_field.is_disabled = true
	owner.callback()
