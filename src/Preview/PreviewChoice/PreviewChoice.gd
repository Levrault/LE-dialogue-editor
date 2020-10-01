extends MarginContainer
class_name PreviewChoice

var value := {} setget set_value

onready var button := $Button
onready var anim := $AnimationPlayer


func set_value(new_value: Dictionary) -> void:
	value = new_value
	button.text = value.text[Editor.locale]


func has_error() -> void:
	anim.play("error")
