extends HBoxContainer

var operator = "equal"
onready var field := $Number


func is_valid() -> bool:
	return not field.text.empty()
