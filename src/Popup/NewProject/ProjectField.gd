extends LineEdit

export var key := ''
var value := '' setget set_value


func set_value(new_value: String) -> void:
	text = new_value
	owner.form_values[key] = new_value
	owner.set(key + "_valid", not new_value.empty())
