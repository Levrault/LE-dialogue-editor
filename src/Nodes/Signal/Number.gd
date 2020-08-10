extends HBoxContainer

onready var field := $Number


func is_valid() -> bool:
	return not field.text.empty()
