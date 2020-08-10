extends HBoxContainer

onready var field := $String


func is_valid() -> bool:
	return not field.text.empty()
