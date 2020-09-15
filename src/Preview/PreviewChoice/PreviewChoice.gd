extends MarginContainer

var value := {} setget set_value
onready var button := $Button


func set_value(new_value: Dictionary) -> void:
	value = new_value
	button.text = value.text[Editor.locale]
