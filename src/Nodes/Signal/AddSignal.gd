extends AddButton


func on_Pressed() -> void:
	# add values
	owner.values["data"][owner.signal_name.text] = owner.get_values()

	# add field
	var new_signal = owner.signal_field.instance()
	owner.container.add_child(new_signal)
	new_signal.signal_name.text = owner.signal_name.text
	new_signal.value.text = owner.params_to_string()
	new_signal.type.text = owner.type_to_string()
	new_signal.connect("field_deleted", owner, "_on_Deleted")

	# set for next signal
	owner.signal_name.text = ""
	owner.type_option.select(owner.Type.empty)
	owner.reset_type()
	owner.add_field.is_disabled = true
